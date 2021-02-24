// Submit form
function submitForm(e){
  e.preventDefault();

  //Get value
  var name = getInputVal('name');
  var email = getInputVal('email');
  var message = getInputVal('message');
  var token = grecaptcha.enterprise.getResponse();

  // Save message
  var xhr = new XMLHttpRequest();
  xhr.open("POST", '/support/request');
  xhr.setRequestHeader("Content-Type", 'application/json');
  var doc = {
      name: name,
      email: email,
      message: message,
      token: token,
  };
  xhr.send(
      JSON.stringify(doc)
  );
  xhr.onload = function () {
     if (xhr.status != 303) {
        document.querySelector('.alert').style.display = 'none';
        document.querySelector('.error').style.display = 'block';
     }
  }

  // Show alert and hide the contact form
  document.querySelector('.alert').style.display = 'block';
  document.getElementById("contactForm").style.display = 'none';
}

// Function to get form value
function getInputVal(id){
  return document.getElementById(id).value;
}

