import * as React from "react";
import * as ReactDOM from "react-dom";

const App = () => {
  const [question, setQuestion] = React.useState("")
  const [answer, setAnswer] = React.useState(null)
  const [loading, setLoading] = React.useState(false)

  React.useEffect(() => {
    fetch('/home/load', {
      method: 'GET',
    }).then(res => console.log(res.json))
  }, [])

  const token = document.querySelector('meta[name="csrf-token"]').content
  const handleSubmit = async (event) => {
    event.preventDefault();
    setLoading(true)
    let body = JSON.stringify({ question })
    const response = await fetch('/home/ask', {
      method: 'POST',
      body: body,
      headers: {
        "X-CSRF-Token": token,
        'Content-Type': 'application/json'
      },
    })
    const data = await response.json()
    setAnswer(data.answer)
    setLoading(false)
  }

  return (<div>
    <form onSubmit={handleSubmit}>
      <label>Enter your name:
        <input
          type="text"
          value={question}
          onChange={(e) => setQuestion(e.target.value)}
        />
      </label>
      <input type="submit" />
    </form>
    {loading ? <p>Loading</p> : <p>{answer}</p>}

  </div>);
};

document.addEventListener("DOMContentLoaded", () => {
  const rootEl = document.getElementById("root");
  ReactDOM.render(<App />, rootEl);
});
