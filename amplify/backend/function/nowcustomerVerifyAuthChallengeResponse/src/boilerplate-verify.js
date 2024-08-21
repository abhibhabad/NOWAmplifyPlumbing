//verifyAuthChallengeResponse simply checks if the challenge code that was stored during the create challenge function matches the code submitted by the user in the app. It then returns whether the answer is correct or not.

function verifyAuthChallengeResponse(event) {
  if (
    event.request.privateChallengeParameters.answer ===
    event.request.challengeAnswer
  ) {
    event.response.answerCorrect = true;
  } else {
    event.response.answerCorrect = false;
  }
}

exports.handler = async (event) => {
  verifyAuthChallengeResponse(event);
};
