const axios = require("axios");
const {buildXVerify} = require("./signature");

const BASE_URL = process.env.PHONEPE_BASE_URL;
const MERCHANT_ID = process.env.PHONEPE_MERCHANT_ID;
const SALT_KEY = process.env.PHONEPE_SALT_KEY;
const SALT_INDEX = process.env.PHONEPE_SALT_INDEX;

// merchantTransactionId from your DB/client
exports.getStatus = async (req, res) => {
  try {
    const {merchantTransactionId} = req.query;
    const path = `/pg/v1/status/${MERCHANT_ID}/${merchantTransactionId}`;

    const xVerify = buildXVerify("", path, SALT_KEY, SALT_INDEX);

    const r = await axios.get(`${BASE_URL}${path}`, {
      headers: {"X-VERIFY": xVerify, "X-MERCHANT-ID": MERCHANT_ID},
    });

    res.send(r.data);
  } catch (e) {
    console.error(e.response?.data || e);
    res.status(500).send({error: "status_failed", detail: e.response?.data || e.message});
  }
};
