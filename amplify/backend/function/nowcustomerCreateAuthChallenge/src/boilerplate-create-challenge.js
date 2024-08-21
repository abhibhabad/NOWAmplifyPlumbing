var aws = require("aws-sdk");
var ses = new aws.SES({ region: "us-east-1" }); // This is your SES region
const digitGenerator = require("crypto-secure-random-digit");

// 1: The sendChallengeCode will take the email address thatâ€™s provided by the user through the app and uses the AWS SDK to send the secret code from the email address that you verified with SES.
function sendChallengeCode(emailAddress, secretCode) {
  var params = {
    Destination: {
      ToAddresses: [emailAddress],
    },
    Message: {
      Body: {
        Text: { Data: secretCode },
      },
      Subject: { Data: "Email Verification Code" },
    },
    Source: "verification@nowmobileordering.com", // This is you SES Identity Email
  };

  return ses.sendEmail(params).promise();
}

exports.handler = async function (event) {
  if (event.request.challengeName === "CUSTOM_CHALLENGE") {
    // Generate a random code for the custom challenge
    const challengeCode = digitGenerator.randomDigits(6).join("");

    event.response.privateChallengeParameters = {};
        // 2: The challenge code will be stored as the answer so when the user receives the challenge code in the email, it can be compared.

    event.response.privateChallengeParameters.answer = challengeCode;

        // 3: The publicChallengeParameters are returned in as a response once the user has provided an email address in the app and triggered the create challenge flow. You can present these values in the app if desired.
    event.response.publicChallengeParameters = {};
    event.response.publicChallengeParameters["fieldTitle"] = "Enter the secret";
    event.response.publicChallengeParameters["fieldHint"] = "Check your email";

    return sendChallengeCode(event.request.userAttributes.email, challengeCode);
  }
};
