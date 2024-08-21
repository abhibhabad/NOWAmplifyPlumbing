/**
 * @type {import('@types/aws-lambda').CreateAuthChallengeTriggerHandler}
 */
exports.handler = async (event) => {
  if (event.request.session.length === 2 && event.request.challengeName === 'CUSTOM_CHALLENGE') {
    event.response.publicChallengeParameters = { trigger: 'true' };

    event.response.privateChallengeParameters = {};
    event.response.privateChallengeParameters.answer = process.env.CHALLENGEANSWER;
  }
  return event;
};

// https://nodejs.org/api/crypto.html#crypto_crypto_randomint_min_max_callback
const {
  randomInt
} = await import('node:crypto');

// Use SES or custom logic to send the secret code to the user.
function sendChallengeCode(emailAddress, secretCode) {
const params = {
    Destination: {
      ToAddresses: [emailAddress],
    },
    Message: {
      Body: {
        Text: { Data: secretCode },
      },
       Subject: { Data: "Email Verification Code" },
    },
    Source: <SES_Identity_Email>, // This is your SES Identity Email
  };
 
 
  return ses.sendEmail(params).promise()

}

//tutorial code
function createAuthChallenge(event) {
  if (event.request.challengeName === 'CUSTOM_CHALLENGE') {
    // Generate a random code for the custom challenge
    const randomDigits = randomInt(6);
    const challengeCode = String(randomDigits).join('');

    // Send the custom challenge to the user
    sendChallengeCode(event.request.userAttributes.email, challengeCode);

    event.response.privateChallengeParameters = {};
    event.response.privateChallengeParameters.answer = challengeCode;
  }
}
 
exports.handler = async (event) => {
  createAuthChallenge(event);
};
