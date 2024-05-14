import click

from conways.conways import Conways


@click.command()
@click.option("-w", "--width", default=80, help="Width of the grid", type=int)
@click.option("-h", "--height", default=40, help="Height of the grid", type=int)
@click.option("--fps", default=15, help="Frames per second", type=int)
@click.option("-s", "--seed", default=42, help="Randomness seed", type=int)
@click.option("-t", "--time", default=30, help="Maximum number of frames to render", type=int)
def main(width: int, height: int, fps: int, seed: int, time: int):
    Conways(width=width, height=height, fps=fps, seed=seed, max_frames=time).run()

