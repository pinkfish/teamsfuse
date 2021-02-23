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
  xhr.open("POST", '/support/request', true);
  xhr.send(formData);

  // Show alert
  document.querySelector('.alert').style.display = 'block';

  // Hide alert after 3 seconds
  setTimeout(function(){
    document.querySelector('.alert').style.display = 'none';
  },3000);
}

// Function to get form value
function getInputVal(id){
  return document.getElementById(id).value;
}

