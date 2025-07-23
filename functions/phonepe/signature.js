const crypto = require("crypto");

exports.buildXVerify = (payloadB64, path, saltKey, saltIndex) => {
  const hash = crypto.createHash("sha256")
      .update(payloadB64 + path + saltKey)
      .digest("hex");
  return `${hash}###${saltIndex}`;
};
