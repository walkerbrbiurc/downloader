#!/usr/bin/env python

import os
import sys
import argparse
import time
import urllib.request
import zipfile
from pathlib import Path
from urllib.parse import urlparse, parse_qs, unquote

CHUNK_SIZE = 1638400
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
CIVITAI_BASE_URL = 'https://civitai.com/api/download/models'

# ==========================================================
# 🔑 Token chumbado (substitua pelo seu token real)
HARD_CODED_TOKEN = "hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# ==========================================================


def get_args():
    parser = argparse.ArgumentParser(
        description='CivitAI Downloader',
    )

    parser.add_argument(
        'model_id',
        type=str,
        help='CivitAI Download Model ID, eg: 46846'
    )

    parser.add_argument(
        'output_path',
        type=str,
        help='Output path, eg: /workspace/stable-diffusion-webui/models/Stable-diffusion'
    )

    return parser.parse_args()


def get_token():
    """Return the hardcoded token directly."""
    if not HARD_CODED_TOKEN or len(HARD_CODED_TOKEN.strip()) == 0:
        raise ValueError("Nenhum token foi definido em HARD_CODED_TOKEN.")
    return HARD_CODED_TOKEN.strip()


def download_file(model_id: str, output_path: str, token: str):
    headers = {
        'Authorization': f'Bearer {token}',
        'User-Agent': USER_AGENT,
    }

    # Disable automatic redirect handling
    class NoRedirection(urllib.request.HTTPErrorProcessor):
        def http_response(self, request, response):
            return response
        https_response = http_response

    url = f'{CIVITAI_BASE_URL}/{model_id}'
    request = urllib.request.Request(url, headers=headers)
    opener = urllib.request.build_opener(NoRedirection)
    response = opener.open(request)

    if response.status in [301, 302, 303, 307, 308]:
        redirect_url = response.getheader('Location')

        # Handle relative redirects
        if redirect_url.startswith('/'):
            base_url = urlparse(url)
            redirect_url = f"{base_url.scheme}://{base_url.netloc}{redirect_url}"

        # Extract filename from redirect URL
        parsed_url = urlparse(redirect_url)
        query_params = parse_qs(parsed_url.query)
        content_disposition = query_params.get('response-content-disposition', [None])[0]

        if content_disposition and 'filename=' in content_disposition:
            filename = unquote(content_disposition.split('filename=')[1].strip('"'))
        else:
            # Fallback: extract filename from URL path
            path = parsed_url.path
            if path and '/' in path:
                filename = path.split('/')[-1]
            else:
                filename = 'downloaded_file'

            if not filename:
                raise Exception('Unable to determine filename')

        response = urllib.request.urlopen(redirect_url)
    elif response.status == 404:
        raise Exception('File not found')
    else:
        raise Exception('No redirect found, something went wrong')

    total_size = response.getheader('Content-Length')
    if total_size is not None:
        total_size = int(total_size)

    output_file = os.path.join(output_path, filename)

    with open(output_file, 'wb') as f:
        downloaded = 0
        start_time = time.time()

        while True:
            chunk_start_time = time.time()
            buffer = response.read(CHUNK_SIZE)
            chunk_end_time = time.time()

            if not buffer:
                break

            downloaded += len(buffer)
            f.write(buffer)
            chunk_time = chunk_end_time - chunk_start_time

            if chunk_time > 0:
                speed = len(buffer) / chunk_time / (1024 ** 2)  # Speed in MB/s

            if total_size is not None:
                progress = downloaded / total_size
                sys.stdout.write(f'\rDownloading: {filename} [{progress*100:.2f}%] - {speed:.2f} MB/s')
                sys.stdout.flush()

    end_time = time.time()
    time_taken = end_time - start_time
    hours, remainder = divmod(time_taken, 3600)
    minutes, seconds = divmod(remainder, 60)

    if hours > 0:
        time_str = f'{int(hours)}h {int(minutes)}m {int(seconds)}s'
    elif minutes > 0:
        time_str = f'{int(minutes)}m {int(seconds)}s'
    else:
        time_str = f'{int(seconds)}s'

    sys.stdout.write('\n')
    print(f'Download completed. File saved as: {filename}')
    print(f'Downloaded in {time_str}')

    if output_file.endswith('.zip'):
        print('Note: The downloaded file is a ZIP archive.')
        try:
            with zipfile.ZipFile(output_file, 'r') as zip_ref:
                zip_ref.extractall(os.path.dirname(output_file))
        except Exception as e:
            print(f'ERROR: Failed to unzip the file. {e}')


def main():
    args = get_args()
    token = get_token()

    try:
        download_file(args.model_id, args.output_path, token)
    except Exception as e:
        print(f'ERROR: {e}')


if __name__ == '__main__':
    main()
