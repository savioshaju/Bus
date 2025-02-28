const bcrypt = require("bcryptjs");

const plainPassword = "password123"; // The original password you used
const hashedPassword = "$2b$10$Stw.F1TuxVtBI8K/herciO2kTBj3/nSZr0.0.3DZ3hOagLIQAMUmK"; // Copy from DB

bcrypt.compare(plainPassword, hashedPassword, (err, result) => {
  if (err) throw err;
  console.log("Password Match:", result);
});
