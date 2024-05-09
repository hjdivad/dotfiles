import time
import random

Living = "x"
Dead = " "
Unspecified = "?"


class Conways:
    width: int
    height: int
    grid: list[list[str]]
    fps: int
    frames_drawn: int
    max_frames: int

    def __init__(
        self, width: int, height: int, fps: int, seed: int, max_frames: int
    ) -> None:
        random.seed(seed)

        self.width = width
        self.height = height
        self.fps = fps
        self.frames_drawn = 0
        self.max_frames = max_frames
        # Create a grid of width x height with random Living or Dead values
        self.grid = [
            [Living if random.random() < 0.5 else Dead for _ in range(width)]
            for _ in range(height)
        ]

    def run(self):
        self.create_canvas()
        self.frames_drawn = 0
        frame_delay = 1 / self.fps
        while self.frames_drawn < self.max_frames:
            start_time = time.time()
            self.draw()
            self.update()
            self.frames_drawn += 1
            elapsed_time = time.time() - start_time
            sleep_time = max(frame_delay - elapsed_time, 0)
            time.sleep(sleep_time)

    def create_canvas(self):
        lines = "".join(["\n" for _ in range(self.height + 2)])
        print(lines)

    def count_live_neighbours(self, i: int, j: int) -> int:
        result = 0

        if i > 0:
            result += 1 if self.grid[i - 1][j] == Living else 0
            if j > 0:
                result += 1 if self.grid[i - 1][j - 1] == Living else 0
            if j < self.width - 1:
                result += 1 if self.grid[i - 1][j + 1] == Living else 0
        if i < self.height - 1:
            result += 1 if self.grid[i + 1][j] == Living else 0
            if j > 0:
                result += 1 if self.grid[i + 1][j - 1] == Living else 0
            if j < self.width - 1:
                result += 1 if self.grid[i + 1][j + 1] == Living else 0

        if j > 0:
            result += 1 if self.grid[i][j - 1] == Living else 0
        if j < self.width - 1:
            result += 1 if self.grid[i][j + 1] == Living else 0

        return result

    def update(self):
        next_grid = [
            [Unspecified for _ in range(self.width)] for _ in range(self.height)
        ]

        for i in range(self.height):
            for j in range(self.width):
                live_neighbours = self.count_live_neighbours(i, j)
                if self.grid[i][j] == Living:
                    next_grid[i][j] = (
                        Living if live_neighbours == 2 or live_neighbours == 3 else Dead
                    )
                else:
                    next_grid[i][j] = Living if live_neighbours == 3 else Dead

        self.grid = next_grid

    def draw(self):
        # Move the cursor up self.height lines
        print("\033[{}A\r".format(self.height + 2), end="")  # Move up and carriage return
        self.print_grid()
        print('\nFrame {}'.format(self.frames_drawn))

    def print_grid(self):
        for row in self.grid:
            for cell in row:
                print(cell, end="")  # Print each cell in the row without a newline
            print()  # After each row, print a newline to start the next row
