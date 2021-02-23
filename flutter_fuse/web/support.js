// Submit form
function submitForm(e){
  e.preventDefault();

  //Get value
  var name = getInputVal('name');
  var email = getInputVal('email');
  var message = getInputVal('message');
  var token = getInputVal("g-recaptcha-response");

  // Save message
  var formData = new FormData(document.getElementById("contactForm"));
  var xhr = new XMLHttpRequest();
  xhr.open("POST", '/support/request');
  xhr.send(formData);

  // Show alert and hide the contact form
  document.querySelector('.alert').style.display = 'block';
  document.getElementById("contactForm").style.display = 'none';
}

// Function to get form value
function getInputVal(id){
  return document.getElementById(id).value;
}

