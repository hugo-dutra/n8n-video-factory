#!/usr/bin/env python3
import json
import sys
import matplotlib
matplotlib.use("Agg")  # importante em ambiente sem display
import matplotlib.pyplot as plt

def main():
    payload = json.load(sys.stdin)

    chart_type = payload.get("type", "bar")  # bar | pie | line
    title = payload.get("title", "")
    out = payload.get("out", "/home/node/processing/chart.png")

    labels = payload.get("labels", [])
    values = payload.get("values", [])

    if not labels or not values or len(labels) != len(values):
        print("Invalid input: labels/values missing or length mismatch", file=sys.stderr)
        sys.exit(2)

    plt.figure()

    if chart_type == "pie":
        plt.pie(values, labels=labels, autopct="%1.1f%%")
        plt.axis("equal")
    elif chart_type == "line":
        plt.plot(labels, values, marker="o")
        plt.xticks(rotation=45, ha="right")
    else:
        plt.bar(labels, values)
        plt.xticks(rotation=45, ha="right")

    if title:
        plt.title(title)

    plt.tight_layout()
    plt.savefig(out, dpi=150)
    print(out)  # retorna o caminho do PNG

if __name__ == "__main__":
    main()
