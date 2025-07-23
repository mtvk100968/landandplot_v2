// PhonePe hits this with final status. Validate signature if spec says.
// Save to Firestore etc.
exports.webhook = async (req, res) => {
  try {
    const payload = req.body;
    console.log("PhonePe webhook:", payload);
    // TODO: verify signature if provided & update Firestore here
    // TODO: update order doc: COMPLETED / FAILED / PENDING
    res.status(200).send("OK");
  } catch (e) {
    console.error(e);
    res.status(500).send("ERR");
  }
};
