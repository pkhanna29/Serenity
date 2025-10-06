const mongoose = require('mongoose');

mongoose.connect('mongodb+srv://p10khanna:10Messi10@serenitydb.mwqbfmx.mongodb.net/?retryWrites=true&w=majority&appName=SerenityDB', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log("Connected to MongoDB");
}).catch((err) => {
  console.error("MongoDB connection error:", err);
});

const GratitudeSchema = new mongoose.Schema({
  entry: String,
  date: { type: Date, default: Date.now }
});

const Gratitude = mongoose.model('Gratitude', GratitudeSchema);


const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/', (req, res) => {
  res.send('Backend is running!');
});

app.post('/gratitude', async (req, res) => {
  const { entry } = req.body;

  try {
    const newEntry = new Gratitude({ entry });
    await newEntry.save();
    res.status(200).json({ message: "Saved to DB" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error saving entry" });
  }
});

app.get('/gratitude/all', async (req, res) => {
  try {
    const entries = await Gratitude.find().sort({ date: -1 });
    res.status(200).json(entries);
  } catch (error) {
    res.status(500).json({ message: "Error fetching entries" });
  }
});


app.post('/chat', async (req, res) => {
  const { prompt } = req.body;
  const reply = `You said: ${prompt}`;
  res.json({ response: reply });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});