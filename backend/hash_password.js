const bcrypt = require("bcryptjs");

const plainPassword = "password123"; // Change this to the real password

bcrypt.hash(plainPassword, 10, (err, hash) => {
  if (err) throw err;
  console.log("New Hashed Password:", hash);
});
