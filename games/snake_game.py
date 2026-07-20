import random
import tkinter as tk


CELL_SIZE = 24
GRID_WIDTH = 24
GRID_HEIGHT = 18
START_DELAY_MS = 120


class SnakeGame:
    def __init__(self, root):
        self.root = root
        self.root.title("Snake Apple Run")
        self.root.resizable(False, False)

        self.canvas = tk.Canvas(
            root,
            width=GRID_WIDTH * CELL_SIZE,
            height=GRID_HEIGHT * CELL_SIZE + 48,
            bg="#111827",
            highlightthickness=0,
        )
        self.canvas.pack()

        self.direction = "Right"
        self.next_direction = "Right"
        self.score = 0
        self.best_score = 0
        self.delay_ms = START_DELAY_MS
        self.paused = False
        self.game_over = False
        self.after_id = None

        self.root.bind("<KeyPress>", self.on_key_press)
        self.reset()

    def reset(self):
        center_x = GRID_WIDTH // 2
        center_y = GRID_HEIGHT // 2
        self.snake = [
            (center_x, center_y),
            (center_x - 1, center_y),
            (center_x - 2, center_y),
        ]
        self.direction = "Right"
        self.next_direction = "Right"
        self.score = 0
        self.delay_ms = START_DELAY_MS
        self.paused = False
        self.game_over = False
        self.apple = self.spawn_apple()

        if self.after_id is not None:
            self.root.after_cancel(self.after_id)
        self.draw()
        self.tick()

    def spawn_apple(self):
        available_cells = [
            (x, y)
            for x in range(GRID_WIDTH)
            for y in range(GRID_HEIGHT)
            if (x, y) not in self.snake
        ]
        return random.choice(available_cells)

    def on_key_press(self, event):
        key = event.keysym
        directions = {
            "Up": "Up",
            "w": "Up",
            "W": "Up",
            "Down": "Down",
            "s": "Down",
            "S": "Down",
            "Left": "Left",
            "a": "Left",
            "A": "Left",
            "Right": "Right",
            "d": "Right",
            "D": "Right",
        }
        opposites = {
            "Up": "Down",
            "Down": "Up",
            "Left": "Right",
            "Right": "Left",
        }

        if key in directions and directions[key] != opposites[self.direction]:
            self.next_direction = directions[key]
        elif key in ("space", "p", "P") and not self.game_over:
            self.paused = not self.paused
            self.draw()
        elif key in ("r", "R", "Return"):
            self.reset()

    def tick(self):
        if not self.paused and not self.game_over:
            self.move()
        self.draw()
        self.after_id = self.root.after(self.delay_ms, self.tick)

    def move(self):
        self.direction = self.next_direction
        head_x, head_y = self.snake[0]

        if self.direction == "Up":
            head_y -= 1
        elif self.direction == "Down":
            head_y += 1
        elif self.direction == "Left":
            head_x -= 1
        elif self.direction == "Right":
            head_x += 1

        new_head = (head_x, head_y)

        hit_wall = head_x < 0 or head_x >= GRID_WIDTH or head_y < 0 or head_y >= GRID_HEIGHT
        hit_self = new_head in self.snake
        if hit_wall or hit_self:
            self.game_over = True
            self.best_score = max(self.best_score, self.score)
            return

        self.snake.insert(0, new_head)

        if new_head == self.apple:
            self.score += 1
            self.best_score = max(self.best_score, self.score)
            self.apple = self.spawn_apple()
            self.delay_ms = max(60, self.delay_ms - 3)
        else:
            self.snake.pop()

    def draw(self):
        self.canvas.delete("all")
        self.draw_header()
        self.draw_grid()
        self.draw_apple()
        self.draw_snake()

        if self.paused:
            self.draw_center_text("Paused", "Press Space to continue")
        if self.game_over:
            self.draw_center_text("Game Over", "Press R or Enter to restart")

    def draw_header(self):
        self.canvas.create_rectangle(
            0,
            0,
            GRID_WIDTH * CELL_SIZE,
            48,
            fill="#0f172a",
            outline="",
        )
        self.canvas.create_text(
            16,
            24,
            text=f"Score: {self.score}",
            fill="#f9fafb",
            font=("Segoe UI", 13, "bold"),
            anchor="w",
        )
        self.canvas.create_text(
            GRID_WIDTH * CELL_SIZE - 16,
            24,
            text=f"Best: {self.best_score}",
            fill="#d1d5db",
            font=("Segoe UI", 12),
            anchor="e",
        )

    def draw_grid(self):
        top = 48
        for x in range(GRID_WIDTH):
            for y in range(GRID_HEIGHT):
                x1 = x * CELL_SIZE
                y1 = top + y * CELL_SIZE
                color = "#111827" if (x + y) % 2 == 0 else "#101522"
                self.canvas.create_rectangle(
                    x1,
                    y1,
                    x1 + CELL_SIZE,
                    y1 + CELL_SIZE,
                    fill=color,
                    outline="",
                )

    def draw_apple(self):
        x, y = self.apple
        pad = 4
        top = 48
        self.canvas.create_oval(
            x * CELL_SIZE + pad,
            top + y * CELL_SIZE + pad,
            (x + 1) * CELL_SIZE - pad,
            top + (y + 1) * CELL_SIZE - pad,
            fill="#ef4444",
            outline="#fecaca",
            width=2,
        )

    def draw_snake(self):
        top = 48
        for index, (x, y) in enumerate(self.snake):
            pad = 3
            fill = "#22c55e" if index == 0 else "#16a34a"
            self.canvas.create_rectangle(
                x * CELL_SIZE + pad,
                top + y * CELL_SIZE + pad,
                (x + 1) * CELL_SIZE - pad,
                top + (y + 1) * CELL_SIZE - pad,
                fill=fill,
                outline="#bbf7d0",
                width=1,
            )

    def draw_center_text(self, title, subtitle):
        width = GRID_WIDTH * CELL_SIZE
        height = GRID_HEIGHT * CELL_SIZE + 48
        self.canvas.create_rectangle(
            56,
            height // 2 - 58,
            width - 56,
            height // 2 + 58,
            fill="#020617",
            outline="#334155",
            width=2,
        )
        self.canvas.create_text(
            width // 2,
            height // 2 - 14,
            text=title,
            fill="#f9fafb",
            font=("Segoe UI", 24, "bold"),
        )
        self.canvas.create_text(
            width // 2,
            height // 2 + 22,
            text=subtitle,
            fill="#cbd5e1",
            font=("Segoe UI", 12),
        )


if __name__ == "__main__":
    window = tk.Tk()
    SnakeGame(window)
    window.mainloop()
