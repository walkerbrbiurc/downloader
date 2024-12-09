#!/usr/bin/env python3
import os
import sys
import urllib.request
from urllib.parse import urlparse, parse_qs, unquote

CHUNK_SIZE = 1638400
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'


def resolve_download_url(url: str) -> str:
    """Resolve the final download URL after redirection."""
    headers = {"User-Agent": USER_AGENT}
    request = urllib.request.Request(url, headers=headers)
    response = urllib.request.urlopen(request)

    if response.status in [301, 302, 303, 307, 308]:
        return response.getheader("Location")
    return url


def download_file(download_url: str, output_dir: str):
    """Download a file from the resolved URL and save it to the specified directory."""
    headers = {"User-Agent": USER_AGENT}
    request = urllib.request.Request(download_url, headers=headers)
    response = urllib.request.urlopen(request)

    # Get filename from Content-Disposition or URL
    content_disposition = response.getheader("Content-Disposition")
    if content_disposition:
        filename = unquote(content_disposition.split("filename=")[1].strip('"'))
    else:
        parsed_url = urlparse(download_url)
        filename = os.path.basename(parsed_url.path)

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    output_file = os.path.join(output_dir, filename)

    # Download file with progress indication
    total_size = response.getheader("Content-Length")
    total_size = int(total_size) if total_size else None

    with open(output_file, "wb") as file:
        downloaded = 0
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

    print(f"\nDownload completed: {output_file}")


def main():
    if len(sys.argv) < 3:
        print("Usage: download-model [URL] [DESTINATION]")
        sys.exit(1)

    url = sys.argv[1]
    destination = sys.argv[2]

    try:
        print(f"Resolving download URL for: {url}")
        download_url = resolve_download_url(url)
        download_file(download_url, destination)
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
