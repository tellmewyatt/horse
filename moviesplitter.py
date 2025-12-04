from moviepy import VideoFileClip, TextClip, CompositeVideoClip, concatenate_videoclips, clips_array
from moviepy.video.fx.Loop import Loop
import os
import random
from argparse import ArgumentParser
import math

available_videos = {}
def get_change_points(total_dur, min_dur=10, max_dur=40):
    durs = []
    while sum(durs) < total_dur:
        durs.append(random.randrange(min_dur, max_dur))
    return durs
def fill_dur_with_random_subclip(clips, total_dur, i, min_dur=10):
    """ Fills a duration with random subclips. i is the location in available videos """
    global available_videos
    clip = None
    if available_videos.get(i) == None:
        clip = random.choice(clips)
        available_videos[i] = [clip.filename]
    else:
        clip = random.choice(clips)
        while clip.filename in available_videos[i]:
            print("in while loop", i)
            clip = random.choice(clips)
        available_videos[i].append(clip.filename)
    if clip.duration < min_dur:
        return clip.with_effects([Loop(duration=total_dur)])
    else:
        start = random.random() * (clip.duration - min_dur)
        return clip.subclipped(start, clip.duration).with_effects([Loop(duration=total_dur)])
def get_sequence(videos, change_points):
    result = [
        fill_dur_with_random_subclip(videos, dur, i) for i, dur in enumerate(change_points)
    ]
    return concatenate_videoclips(result)
def crop_video(clip, width=1920/2, height=1080/2):
    """ Crops and centers a clip given a width and height """
    aspect_ratio = width / height
    clip_aspect_ratio = clip.size[0] / clip.size[1]
    if aspect_ratio > clip_aspect_ratio:
        clip = clip.resized(width=width)
        y1 = math.floor(clip.size[1] - height) / 2
        return clip.cropped(x1=0, y1=y1, x2=width, y2=y1 + height)
    else:
        clip = clip.resized(height=height)
        x1 = math.floor(clip.size[0] - width) / 2
        return clip.cropped(x1=x1, y1=0, x2=x1 + width, y2=height)
    
if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("video_dir")
    parser.add_argument("duration", type=int)
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    parser.add_argument("--outfile", type=str, default="horse_video.mp4")
    parser.add_argument("--fps", type=int, default=30)
    args = parser.parse_args()
    videos = []
    for filename in os.listdir(args.video_dir):
        if filename.endswith(".mp4") and not filename.startswith("."):
            videos.append(
                crop_video(
                    VideoFileClip(os.path.join(args.video_dir, filename))
                )
            )
    change_points = get_change_points(args.duration)
    n = 2
    # Create a square matrix
    final_array = [[get_sequence(videos, change_points) for x in range(0, n)] for x in range(0, n)]
    final = clips_array(final_array).without_audio()
    final.write_videofile(args.outfile, fps=args.fps, preset='ultrafast')
