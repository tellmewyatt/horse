from moviepy import VideoFileClip, TextClip, CompositeVideoClip, concatenate_videoclips, clips_array
from moviepy.video.fx.Loop import Loop
import os
import random
from argparse import ArgumentParser


def get_change_points(total_dur, min_dur=10, max_dur=40):
    durs = []
    while sum(durs) < total_dur:
        durs.append(random.randrange(min_dur, max_dur))
    return durs
def fill_dur_with_random_subclip(clips, total_dur, min_dur=10):
    clip = random.choice(clips)
    if clip.duration < min_dur:
        return clip.with_effects([Loop(duration=total_dur)])
    else:
        start = random.random() * (clip.duration - min_dur)
        return clip.subclipped(start, clip.duration).with_effects([Loop(duration=total_dur)])
def get_sequence(videos, change_points):
    return concatenate_videoclips([fill_dur_with_random_subclip(videos, dur) for dur in change_points])
if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("video_dir")
    parser.add_argument("duration", type=int)
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    parser.add_argument("--outfile", type=str, default="horse_video.mp4")
    args = parser.parse_args()
    videos = []
    for filename in os.listdir(args.video_dir):
        if filename.endswith(".mp4") and not filename.startswith("."):
            videos.append(VideoFileClip(os.path.join(args.video_dir, filename)).resized((args.width / 2, args.height / 2)))
    change_points = get_change_points(args.duration)
    n = 2
    # Create a square matrix
    final_array = [[get_sequence(videos, change_points) for x in range(0, n)] for x in range(0, n)]
    final = clips_array(final_array).without_audio()
    final.write_videofile(args.outfile)
