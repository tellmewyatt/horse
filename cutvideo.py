from moviepy import VideoFileClip, TextClip, CompositeVideoClip, concatenate_videoclips, clips_array
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("input_file")
parser.add_argument("output_file")
parser.add_argument("start", type=int, default=0)
parser.add_argument("end", type=int, default=0)
args = parser.parse_args()


video = VideoFileClip(args.input_file)
video.subclipped(args.start, video.duration - args.end).write_videofile(args.output_file)
