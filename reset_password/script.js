import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { verifyPasswordResetCode, confirmPasswordReset } from "firebase/auth";

var input;

document.addEventListener('DOMContentLoaded', () => {
    // TODO: Implement getParameterByName()

    // Get the action to complete.
    const mode = getParameterByName('mode');
    // Get the one-time code from the query parameter.
    const actionCode = getParameterByName('oobCode');
    // (Optional) Get the continue URL from the query parameter if available.
    const continueUrl = getParameterByName('continueUrl');
    // (Optional) Get the language code if available.
    const lang = getParameterByName('lang') || 'en';

    // Configure the Firebase SDK.
    // This is the minimum configuration required for the API to be used.
    const config = {
        'apiKey': "AIzaSyAaRSbp_jrsSpoJASaSTy8wBt_pHX2_ttc"  // Copy this key from the web initialization
        // snippet found in the Firebase console.
    };
    const app = initializeApp(config);
    const auth = getAuth(app);

    // Handle the user management action.
    switch (mode) {
        case 'resetPassword':
            // Display reset password handler and UI.
            handleResetPassword(auth, actionCode, continueUrl, lang);
            break;
        case 'recoverEmail':
            // Display email recovery handler and UI.
            handleRecoverEmail(auth, actionCode, lang);
            break;
        case 'verifyEmail':
            // Display email verification handler and UI.
            handleVerifyEmail(auth, actionCode, continueUrl, lang);
            break;
        default:
        // Error: invalid mode.
    }
}, false);

function handleResetPassword(auth, actionCode, continueUrl, lang) {
    // Localize the UI to the selected language as determined by the lang
    // parameter.

    // Verify the password reset code is valid.
    verifyPasswordResetCode(auth, actionCode).then((email) => {
        const accountEmail = email;

        // TODO: Show the reset screen with the user's email and ask the user for
        // the new password.
        const newPassword = "...";
        newPassword = check();

        // Save the new password.
        confirmPasswordReset(auth, actionCode, newPassword).then((resp) => {
            // Password reset has been confirmed and new password updated.

            // TODO: Display a link back to the app, or sign-in the user directly
            // if the page belongs to the same domain as the app:
            // auth.signInWithEmailAndPassword(accountEmail, newPassword);

            // TODO: If a continue URL is available, display a button which on
            // click redirects the user back to the app via continueUrl with
            // additional state determined from that URL's parameters.
        }).catch((error) => {
            // Error occurred during confirmation. The code might have expired or the
            // password is too weak.
        });
    }).catch((error) => {
        // Invalid or expired action code. Ask user to try to reset the password
        // again.
    });
}

var is_visible = false;

function see() {
    input = document.getElementById("password");
    var see = document.getElementById("see");

    if (is_visible) {
        input.type = 'password';
        is_visible = false;
        see.style.color = 'gray';
    }
    else {
        input.type = 'text';
        is_visible = true;
        see.style.color = '#262626';
    }

}

function check() {
    input = document.getElementById("password").value;

    input = input.trim();
    document.getElementById("password").value = input;
    document.getElementById("count").innerText = "Length : " + input.length;
    if (input.length > 7) {
        document.getElementById("check0").style.color = "green";
    }
    else {
        document.getElementById("check0").style.color = "red";
    }

    if (/[A-Z]/.test(input)) {
        document.getElementById("check1").style.color = "green";
    }
    else {
        document.getElementById("check1").style.color = "red";
    }

    if ((input.length - input.replace(/[a-z]/g, '').length >= 3)) {
        document.getElementById("check2").style.color = "green";
    }
    else {
        document.getElementById("check2").style.color = "red";
    }

    if (input.match(/[0-9]/i)) {
        document.getElementById("check3").style.color = "green";
    }
    else {
        document.getElementById("check3").style.color = "red";
    }
    const specialChars = /[`!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/;
    if (specialChars.test(input) == false) {
        document.getElementById("check4").style.color = "red";
    }
    else {
        document.getElementById("check4").style.color = "green";
    }
    return input;
}
