#!/bin/python3
"""
Prints http response using requests
"""
import requests

def lambda_handler(event, context):
  """
  main function
  """
  x = requests.get("https://www.google.com")
  print(x)

if __name__ == '__main__':
    lambda_handler(event, context)
