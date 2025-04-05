import pandas as pd


def load_csv_data(filepath):
    # Automatically detect if the file is CSV or Excel based on extension
    if filepath.endswith(".csv"):
        # Read CSV file, using only columns A to C
        data = pd.read_csv(filepath, skiprows=1, usecols=[0, 1, 2])
    elif filepath.endswith((".xls", ".xlsx")):
        # Read Excel file, specifying sheet and columns A to C
        data = pd.read_excel(filepath, sheet_name="METADATA", skiprows=1, usecols="A:C")
    else:
        raise ValueError("Unsupported file type. Please use a CSV or Excel file.")

    return data


import matplotlib.pyplot as plt
from io import BytesIO
import base64


def generate_graph(data):
    # Define Material-like color palette
    material_colors = ["#6200EE", "#03DAC5", "#FF0266", "#3700B3", "#BB86FC"]

    # Plot data with custom styling
    plt.figure(
        figsize=(6, 0.25), facecolor="#FAFAFA"
    )  # Light grey background for Material feel
    ax = data.plot(kind="line", color=material_colors, linewidth=2, legend=True)

    # Customize title and labels to have a Material feel
    ax.set_title(
        "Data Visualization", fontsize=18, fontweight="bold", color="#333", pad=20
    )
    ax.set_xlabel(
        "X-axis Label", fontsize=14, color="#555"
    )  # Customize based on your data
    ax.set_ylabel("Y-axis Label", fontsize=14, color="#555")

    # Remove gridlines and add minimalistic ticks
    ax.grid(False)
    ax.tick_params(axis="both", which="major", labelsize=12, color="#888", length=5)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#888")
    ax.spines["bottom"].set_color("#888")

    # Set legend with Material style
    ax.legend(frameon=False, loc="best", fontsize=12)

    # Save the plot to a BytesIO object in memory
    buffer = BytesIO()
    plt.savefig(buffer, format="png", bbox_inches="tight", transparent=True)
    buffer.seek(0)

    # Encode the image in base64
    graph_image = base64.b64encode(buffer.getvalue()).decode()
    buffer.close()

    # Return the base64 string for embedding in HTML
    return graph_image
