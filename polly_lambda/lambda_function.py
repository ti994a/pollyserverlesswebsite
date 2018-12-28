import boto3
import os
import urllib.parse
from contextlib import closing

polly = boto3.client('polly')
s3 = boto3.resource('s3')

def lambda_handler(event, context):
    
    # output format for synthesized audio file - e.g. mp3
    output = os.environ['output']
    # comma delimited list of languages we'll support - e.g. en,fr, ...
    supported_languages = os.environ['supported_languages'].split(',')
    # default language if one is not specified in imput file name, or we do not support language specified in input file name
    default_language = os.environ['default_language']
    # output bucket for synthesized speech files
    output_bucket = os.environ['polly_bucket']

    s3_bucket = event['Records'][0]['s3']['bucket']['name']
    key = urlib.parse.unquote_plus(event['Records'][0]['s3']['object']['key']), encoding='utf-8')

    try:
        whole_filename, file_extension = os.path.splitext(key)
        filename = whole_filename.split("/")[-1]
        text = str(s3.Object(s3_bucket, key).get()['Body'].read(), 'utf-8')
        # Get the language from the file_name.lang.md or file_name.md (if no language specified)
        language = filename.split(".")[-1] 
        voice_language = language if language in supported_languages else default_language

        # Look up voice based on language
        voice_id = os.environ[voice_language]

        # Go ahead and synthesize speech
        response = polly.synthesize_speech(
            OutputFormat=output,
            Text=text,
            VoiceID=voice_id
        )

        output_file_name = "{}.{}".format(filename, output)
        temp_output_file = os.path.join("/tmp", output_file_name)

        if "AudioStream" in response:
            with closing(response['AudioStream']) as stream:
                with open(temp_output_file, "ab") as f:
                    f.write(stream.read())

        s3.Object(output_bucket, output_file_name).upload_file(temp_output_file),ExtraArgs={'ACL':'public-read'})
    
    except Exception as e:
        print('Error caught in Lambda')
        raise e







