mod repl;
mod snap;

use clap::{Parser, Subcommand};
use repl::{Fail, PREAMBLE, Repl};
use serde_json::json;
use std::io::Read;
use std::time::Duration;

#[derive(Parser)]
#[command(name = "vexaim", version, about = "Run MicroPython on a VEX AIM robot over USB.\nThe robot's USB user port is a MicroPython REPL; `exec` sends code to it and returns the output.")]
struct Cli {
    /// Machine-readable JSON output
    #[arg(long, global = true)]
    json: bool,
    /// Which robot to use when several are plugged in (0-based, see `doctor`)
    #[arg(long, global = true)]
    device: Option<usize>,
    #[command(subcommand)]
    cmd: Cmd,
}

#[derive(Subcommand)]
enum Cmd {
    /// Check the USB connection, REPL, battery; print fixes if something is wrong
    Doctor,
    /// Run Python on the robot. CODE, or -f FILE, or "-" for stdin. State (variables, `robot`) persists between calls.
    Exec {
        code: Option<String>,
        #[arg(short, long)]
        file: Option<String>,
        /// Seconds before the program is interrupted (Ctrl-C)
        #[arg(short, long, default_value_t = 30)]
        timeout: u64,
        /// Do not auto-create `robot = Robot()` (and the vex imports)
        #[arg(long)]
        no_preamble: bool,
    },
    /// Emergency stop: interrupt the running program, stop wheels and sound
    Stop,
    /// Battery, heading, position as JSON
    Info,
    /// Save one camera frame from the robot as a JPEG (the robot's camera appears as a normal USB webcam)
    Snap {
        /// Output file (default: vexaim-snap-<unix-time>.jpg in the current directory)
        #[arg(short, long)]
        output: Option<String>,
    },
}

fn out(cli_json: bool, v: serde_json::Value, human: impl FnOnce() -> String) {
    if cli_json { println!("{v}") } else { println!("{}", human()) }
}

fn run(cli: &Cli) -> Result<i32, Fail> {
    match &cli.cmd {
        Cmd::Doctor => doctor(cli),
        Cmd::Stop => {
            let dev = repl::pick(repl::devices()?, cli.device)?;
            let mut r = Repl::open(&dev)?;
            let res = smol::block_on(async {
                r.sync().await?;
                let x = r.exec(&format!("{PREAMBLE}robot.stop_all_movement()\ntry:\n    robot.sound.stop()\nexcept Exception:\n    pass\nwait(400, MSEC)\nprint('stopped', robot.is_stopped())\n"), Duration::from_secs(5)).await?;
                r.close().await;
                Ok::<_, Fail>(x)
            })?;
            out(cli.json, json!({"ok": res.stderr.is_empty(), "stdout": res.stdout, "stderr": res.stderr}), || format!("{}{}", res.stdout, res.stderr));
            Ok(if res.stderr.is_empty() { 0 } else { 1 })
        }
        Cmd::Snap { output } => match snap::snap(output.as_deref()) {
            Ok(r) => {
                out(cli.json, json!({"ok": true, "path": r.path, "width": r.width, "height": r.height, "bytes": r.bytes}), || format!("saved {} ({}x{}, {} bytes)", r.path, r.width, r.height, r.bytes));
                Ok(0)
            }
            Err(e) => Err(Fail::Io(format!("camera: {e}"))),
        },
        Cmd::Info => {
            let code = format!("import json\nprint(json.dumps({{'battery_pct': robot.get_battery_level(), 'heading': robot.inertial.get_heading(), 'x_mm': robot.get_x_position(), 'y_mm': robot.get_y_position(), 'stopped': robot.is_stopped()}}))\n");
            run_exec(cli, &code, 10, true)
        }
        Cmd::Exec { code, file, timeout, no_preamble } => {
            let src = match (code, file) {
                (Some(c), None) if c == "-" => { let mut s = String::new(); std::io::stdin().read_to_string(&mut s).map_err(|e| Fail::Io(e.to_string()))?; s }
                (Some(c), None) => c.clone(),
                (None, Some(f)) => std::fs::read_to_string(f).map_err(|e| Fail::Io(format!("{f}: {e}")))?,
                _ => return Err(Fail::Io("give CODE, or -f FILE, or '-' for stdin".into())),
            };
            run_exec(cli, &src, *timeout, !*no_preamble)
        }
    }
}

fn run_exec(cli: &Cli, src: &str, timeout: u64, preamble: bool) -> Result<i32, Fail> {
    let dev = repl::pick(repl::devices()?, cli.device)?;
    let mut r = Repl::open(&dev)?;
    let res = smol::block_on(async {
        if preamble {
            // separate call so line numbers in tracebacks match the student's code
            let p = r.exec(PREAMBLE, Duration::from_secs(10)).await?;
            if !p.stderr.is_empty() { return Ok::<_, Fail>(p); }
        }
        let x = r.exec(src, Duration::from_secs(timeout)).await?;
        r.close().await;
        Ok(x)
    })?;
    let ok = res.stderr.is_empty() && !res.timed_out;
    out(cli.json, json!({"ok": ok, "stdout": res.stdout, "stderr": res.stderr, "timed_out": res.timed_out, "possible_output_truncation": res.timed_out && res.stdout.len() >= 1500, "elapsed_ms": res.elapsed.as_millis() as u64}), || {
        let mut s = res.stdout.replace("\r\n", "\n");
        if res.timed_out {
            s.push_str(&format!("[timed out after {timeout}s: program interrupted]\n"));
            if res.stdout.len() >= 1500 {
                s.push_str("[hint: the robot's USB output buffer overflows when more than ~2 KB is printed in one burst, and the rest is lost. Print less, or print in chunks with wait(50, MSEC) between them.]\n");
            }
        }
        if !res.stderr.is_empty() { s.push_str(&res.stderr.replace("\r\n", "\n")); }
        s.trim_end().to_string()
    });
    Ok(if ok { 0 } else { 1 })
}

fn doctor(cli: &Cli) -> Result<i32, Fail> {
    let mut checks: Vec<serde_json::Value> = Vec::new();
    let mut ready = true;
    let mut add = |name: &str, ok: bool, detail: String, hint: &str| {
        if !ok { ready = false; }
        checks.push(json!({"check": name, "ok": ok, "detail": detail, "fix": if ok { "" } else { hint }}));
    };
    let devs = match repl::devices() {
        Ok(d) => d,
        Err(e) => { add("usb-discovery", false, e.to_string(), "re-plug the cable"); vec![] }
    };
    add("robot-detected", !devs.is_empty(), format!("{} device(s)", devs.len()),
        "Plug the AIM into this computer with its USB cable (a data cable, not charge-only) and turn the robot on.");
    for (i, d) in devs.iter().enumerate() {
        add(&format!("device{i}-ports"), d.user_port().is_some(),
            format!("system={} user={}", d.system_port().port_info.port_name, d.user_port().map(|u| u.port_info.port_name.clone()).unwrap_or("none".into())),
            "Re-plug the robot. If it persists, the USB interface layout is unexpected: report it.");
    }
    if let Ok(dev) = repl::pick(devs.clone(), cli.device) {
        match Repl::open(&dev) {
            Err(e) => add("open-ports", false, e.to_string(), "Linux: run linux/install-udev.sh once and re-plug; Windows/macOS: close VEXcode/other serial tools."),
            Ok(mut r) => {
                add("open-ports", true, "opened".into(), "");
                let res = smol::block_on(async {
                    let x = r.exec(&format!("{PREAMBLE}import json,sys\nprint(json.dumps({{'battery_pct': robot.get_battery_level(), 'micropython_core': '.'.join(str(n) for n in sys.implementation.version[:3]), 'python_compat': sys.version.split(';')[0]}}))\n"), Duration::from_secs(10)).await;
                    r.close().await;
                    x
                });
                match res {
                    Ok(x) if x.stderr.is_empty() && !x.timed_out => add("repl", true, x.stdout.trim().to_string(), ""),
                    Ok(x) => add("repl", false, format!("{}{}", x.stdout, x.stderr), "Press the robot's stop button / reboot it, then retry."),
                    Err(e) => add("repl", false, e.to_string(), "Wait 30 s after plugging in (Linux ModemManager), then retry."),
                }
            }
        }
    }
    let verdict = if ready { "ready" } else { "not ready" };
    if cli.json {
        println!("{}", json!({"verdict": verdict, "checks": checks}));
    } else {
        for c in &checks {
            println!("[{}] {}: {}", if c["ok"] == true { "ok" } else { "FAIL" }, c["check"].as_str().unwrap(), c["detail"].as_str().unwrap());
            if c["ok"] == false { println!("       fix: {}", c["fix"].as_str().unwrap()); }
        }
        println!("verdict: {verdict}");
    }
    Ok(if ready { 0 } else { 1 })
}

fn main() {
    let cli = Cli::parse();
    match run(&cli) {
        Ok(code) => std::process::exit(code),
        Err(e) => {
            if cli.json { println!("{}", json!({"ok": false, "error": e.to_string()})) } else { eprintln!("error: {e}") }
            std::process::exit(2);
        }
    }
}
