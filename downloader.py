#!/usr/bin/env python3
import os
import sys
import argparse
import time
import urllib.request
from urllib.parse import urlparse, parse_qs, unquote
from pathlib import Path

CHUNK_SIZE = 1638400
TOKEN_FILE = Path.home() / '.civitai' / 'config'
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'


def get_args():
    parser = argparse.ArgumentParser(description="CivitAI Downloader")
    parser.add_argument(
        "url",
        type=str,
        help="CivitAI model or version URL, e.g., https://civitai.com/models/458760?modelVersionId=973878",
    )
    parser.add_argument(
        "output_path",
        type=str,
        help="Output directory, e.g., /workspace/models",
    )
    return parser.parse_args()


def get_token():
    try:
        with open(TOKEN_FILE, "r") as file:
            return file.read().strip()
    except FileNotFoundError:
        return None


def store_token(token: str):
    TOKEN_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(TOKEN_FILE, "w") as file:
        file.write(token)


def prompt_for_token():
    token = input("Please enter your CivitAI API token: ")
    store_token(token)
    return token


def resolve_download_url(url: str, token: str):
    headers = {"Authorization": f"Bearer {token}", "User-Agent": USER_AGENT}
    request = urllib.request.Request(url, headers=headers)
    response = urllib.request.urlopen(request)

    if response.status in [301, 302, 303, 307, 308]:
        return response.getheader("Location")
    return url


def download_file(download_url: str, output_dir: str, token: str):
    headers = {"Authorization": f"Bearer {token}", "User-Agent": USER_AGENT}
    request = urllib.request.Request(download_url, headers=headers)
    response = urllib.request.urlopen(request)

    content_disposition = response.getheader("Content-Disposition")
    if content_disposition:
        filename = unquote(content_disposition.split("filename=")[1].strip('"'))
    else:
        parsed_url = urlparse(download_url)
        filename = os.path.basename(parsed_url.path)

    output_file = os.path.join(output_dir, filename)
    os.makedirs(output_dir, exist_ok=True)

    total_size = response.getheader("Content-Length")
    total_size = int(total_size) if total_size else None

    with open(output_file, "wb") as file:
        downloaded = 0
        start_time = time.time()

        while True:
            chunk = response.read(CHUNK_SIZE)
            if not chunk:
                break

            file.write(chunk)
            downloaded += len(chunk)
            if total_size:
                progress = (downloaded / total_size) * 100
                sys.stdout.write(f"\rDownloading: {filename} [{progress:.2f}%]")
                sys.stdout.flush()

    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"\nDownload completed: {output_file} (in {elapsed_time:.2f} seconds)")


def main():
    args = get_args()
    token = get_token() or prompt_for_token()

    # Parse model and version IDs from the URL
    parsed_url = urlparse(args.url)
    query_params = parse_qs(parsed_url.query)
    model_version_id = query_params.get("modelVersionId", [None])[0]

    if model_version_id:
        download_url = f"https://civitai.com/api/download/models/{model_version_id}"
    else:
        raise ValueError("The provided URL does not contain a modelVersionId.")

    try:
        download_url = resolve_download_url(download_url, token)
        download_file(download_url, args.output_path, token)
    except Exception as e:
        print(f"ERROR: {e}")


if __name__ == "__main__":
    main()
