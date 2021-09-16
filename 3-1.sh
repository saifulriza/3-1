#!bin/bash
export PROJECT_ID=$(gcloud config get-value project) 
export BUCKET_NAME=$(gcloud config get-value project)-bucket
mkdir gcf_hello_world 
cd gcf_hello_world
cat <<EOF > index.js
/**
* Background Cloud Function to be triggered by Pub/Sub.
* This function is exported by index.js, and executed when
* the trigger topic receives a message.
*
* @param {object} data The event payload.
* @param {object} context The event metadata.
*/
exports.helloWorld = (data, context) => {
const pubSubMessage = data;
const name = pubSubMessage.data
    ? Buffer.from(pubSubMessage.data, 'base64').toString() : "Hello World";
console.log(`My Cloud Function: ${name}`);
};
EOF

gsutil mb -p $PROJECT_ID gs://$BUCKET_NAME

gcloud functions deploy helloWorld \
  --stage-bucket $BUCKET_NAME \
  --trigger-topic hello_world \
  --runtime nodejs8

gcloud functions describe helloWorld

DATA=$(printf 'Hello World!'|base64) && gcloud functions call helloWorld --data '{"data":"'$DATA'"}'

gcloud functions logs read helloWorld

