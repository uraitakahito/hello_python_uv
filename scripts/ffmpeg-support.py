import os
import re
import subprocess

target_dir = "/Users/takahito/MovementDisorders/VIDEO_TS"
output_dir = "/Users/takahito/tmp/movies"
timeout = 1800

vobs = [f for f in os.listdir(target_dir) if re.match(r".*\.VOB", f)]

for vob in vobs:
    mp4 = os.path.splitext(vob)[0] + ".mp4"
    vob_path = os.path.join(target_dir, vob)
    mp4_path = os.path.join(output_dir, mp4)
    print(f"{vob_path = }")
    print(f"{mp4_path = }")
    commands = [
        "ffmpeg",
        "-i",
        vob_path,
        "-vcodec",
        "libxvid",
        "-qscale:v",
        "0",
        mp4_path,
    ]
    print(f"{' '.join(commands)}")
    res = subprocess.run(
        commands,
        capture_output=True,
        check=True,
        timeout=timeout,
    )

    # print("return code: {}".format(res.returncode))
    print(f"{res.stdout.decode()}")
    print(f"{res.stderr.decode()}")
