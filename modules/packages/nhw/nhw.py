#!/usr/bin/env python3
import argparse
import json
import os
import socket
import subprocess
from pathlib import Path


def mkCmd(cmd: str) -> list[str]:
    return cmd.split(" ")


def get_build_host(host: str) -> str:
    if host == "duet3":
        return "oracle"
    else:
        return host


def clean() -> None:
    cmd = mkCmd("nh clean all")
    subprocess.run(cmd)


def run(type: str, mode: str, host: str, flake_path: Path | str, remote: bool, update):
    custom_env = os.environ.copy()
    custom_env["NH_FLAKE"] = str(flake_path)
    command = f"nh {type} {mode} -H {host} --accept-flake-config"
    cmd = mkCmd(command)
    if remote:
        cmd.extend(["--build-host", get_build_host(host), "--target-host", host])
    if update is True:
        cmd.extend(["-u"])
    elif update is not None:
        cmd.extend(["-U", update])
    subprocess.run(cmd, env=custom_env)


def get_hosts(hosts: dict) -> dict[str, str]:
    output: dict[str, str] = {}
    for host, info in hosts.items():
        system = info.get("system")
        host_type = info.get("hostType")
        if system == "":
            continue
        if host_type == "darwin":
            output[host] = "darwin"
        elif host_type == "home":
            output[host] = "home"
        elif host_type == "nixos":
            output[host] = "os"
    return output


def parse_flake(flake_url: Path | str):
    cmd = mkCmd(f"nix eval {flake_url}#hosts --json --accept-flake-config")
    outputs = subprocess.run(cmd, text=True, capture_output=True)
    hosts = json.loads(outputs.stdout)
    return get_hosts(hosts)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", type=str, help="Mode to run nh in")
    parser.add_argument(
        "--flake",
        "-F",
        type=Path,
        help="Path to flake. Defaults to NH_FLAKE",
        default=Path(os.environ["NH_FLAKE"]).expanduser()
        if "NH_FLAKE" in os.environ
        else None,
    )
    parser.add_argument(
        "--host",
        "-H",
        type=str,
        help="Host to update. Must be a host in flake. Defaults to machine hostname.",
        default=socket.gethostname(),
    )
    parser.add_argument("--remote", "-R", action="store_true", help="build on remote")
    parser.add_argument(
        "--update",
        "-u",
        nargs="?",
        const=True,
        help="Update all inputs without argument or specified argument",
    )
    args = parser.parse_args()
    if args.mode == "clean":
        clean()
        return
    flake_hosts = parse_flake(args.flake)
    type = flake_hosts.get(args.host)
    if type is None:
        print(f"\033[31mError: Host {args.host} not in flake\033[0m")
        return
    run(type, args.mode, args.host, args.flake, args.remote, args.update)


if __name__ == "__main__":
    main()
