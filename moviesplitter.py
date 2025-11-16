from moviepy import VideoFileClip, TextClip, CompositeVideoClip, concatenate_videoclips, clips_array
import os
import random

dir = "/media/wyatt/X9 Pro/horse_videos/to_use"
aspect_ratio = [16,9]
videos = []
for filename in os.listdir(dir):
    if filename.endswith(".mp4") and not filename.startswith("."):
        videos.append(VideoFileClip(os.path.join(dir, filename)).resized((640,480)))

def random_subclip(clips, max_dur = 20):
    clip = random.choice(clips)
    if clip.duration < max_dur:
        return clip.subclipped(random.random() * clip.duration, clip.duration)
    else:
        inskip = random.random() * clip.duration;
        return clip.subclipped(inskip, min(inskip + random.random() * max_dur, clip.duration))

def get_random_sequence(clips, duration):
    current_dur = 0
    subclips = []
    while current_dur < duration:
        clip = random_subclip(clips)
        current_dur = current_dur + clip.duration;
        subclips.append(clip)
    return concatenate_videoclips(subclips)
def get_row(videos, duration, columns=2):
    return [get_random_sequence(videos, 60 * 7) for i in range(0, columns)]
dur = 20
n = 2
final_array = [get_row(videos, dur, n) for x in range(0, n)]
print(final_array)
final = clips_array(final_array)
final = final.resized((640, 480))
final.write_videofile("test.mp4")
