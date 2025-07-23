const axios = require("axios");
const {buildXVerify} = require("./signature");

const BASE_URL = process.env.PHONEPE_BASE_URL;
const MERCHANT_ID = process.env.PHONEPE_MERCHANT_ID;
const SALT_KEY = process.env.PHONEPE_SALT_KEY;
const SALT_INDEX = process.env.PHONEPE_SALT_INDEX;

// amount in paise, merchantUserId, callbackUrl come from client
exports.createOrder = async (req, res) => {
  try {
    const {amount, merchantUserId, callbackUrl} = req.body;

    const body = {
      merchantId: MERCHANT_ID,
      merchantTransactionId: crypto.randomUUID(),
      amount,
      merchantUserId,
      callbackUrl,
      paymentInstrument: {type: "PAY_PAGE"},
    };

    const payloadB64 = Buffer.from(JSON.stringify(body)).toString("base64");
    const xVerify = buildXVerify(payloadB64, "/pg/v1/pay", SALT_KEY, SALT_INDEX);

    const r = await axios.post(`${BASE_URL}/pg/v1/pay`, {request: payloadB64}, {
      headers: {
        "Content-Type": "application/json",
        "X-VERIFY": xVerify,
        "X-MERCHANT-ID": MERCHANT_ID,
      },
    });

    res.send(r.data); // contains token/orderId/etc.
  } catch (e) {
    console.error(e.response?.data || e);
    res.status(500).send({error: "create_order_failed", detail: e.response?.data || e.message});
  }
};
