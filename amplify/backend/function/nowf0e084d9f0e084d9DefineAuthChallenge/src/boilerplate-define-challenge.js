/**
 * @type {import('@types/aws-lambda').DefineAuthChallengeTriggerHandler}
 */
exports.handler = async (event) => {
  if (event.request.session.length === 1 && event.request.session[0].challengeName === 'SRP_A') {
    event.response.issueTokens = false;
    event.response.failAuthentication = false;
    event.response.challengeName = 'PASSWORD_VERIFIER';
  } else if (
    event.request.session.length === 2 &&
    event.request.session[1].challengeName === 'PASSWORD_VERIFIER' &&
    event.request.session[1].challengeResult === true
  ) {
    event.response.issueTokens = false;
    event.response.failAuthentication = false;
    event.response.challengeName = 'CUSTOM_CHALLENGE';
  } else if (
    event.request.session.length === 3 &&
    event.request.session[2].challengeName === 'CUSTOM_CHALLENGE' &&
    event.request.session[2].challengeResult === true
  ) {
    event.response.issueTokens = true;
    event.response.failAuthentication = false;
  } else {
    event.response.issueTokens = false;
    event.response.failAuthentication = true;
  }

  return event;
};

//tutorial code 
exports.handler = async function(event) {
    const singleSessionLengthAndSRP = event.request.session.length === 1 &&
    event.request.session[0].challengeName === 'SRP_A';
    const secondSessionCustomChallenge = event.request.session.length === 2 &&
    event.request.session[1].challengeName === 'CUSTOM_CHALLENGE' &&
    event.request.session[1].challengeResult === true

  if (singleSessionLengthAndSRP) {
    event.response.issueTokens = false;
    event.response.failAuthentication = false;
    event.response.challengeName = 'CUSTOM_CHALLENGE';
  } else if (secondSessionCustomChallenge) {
    event.response.issueTokens = true;
    event.response.failAuthentication = false;
    event.response.challengeName = 'CUSTOM_CHALLENGE';
  } else {
    event.response.issueTokens = false;
    event.response.failAuthentication = true;
  }
};
