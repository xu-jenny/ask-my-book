import * as React from "react";
import * as ReactDOM from "react-dom";

const App = () => {
  const [question, setQuestion] = React.useState("")
  const [answer, setAnswer] = React.useState(null)
  const [loading, setLoading] = React.useState(false)

  const [file, setFile] = React.useState({})

  React.useEffect(() => {
    fetch('/home/load', {
      method: 'GET',
    }).then(res => res.json()).then(res => console.log(res))
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
    console.log(response)
    console.log(response.body)
    const data = await response.json()
    console.log(data)
    setAnswer(data.answer)
    setLoading(false)
  }

  const handleFileUpload = (e) => {
    console.log(e.target.files[0])
    setFile(e.target.files[0])
  }

  const handleFileSubmit = async (e) => {
    e.preventDefault()
    const form = new FormData()
    form.append("pdf", file)
    const response = await fetch(`/home/pdf`, {
      method: "POST",
      body: form,
      headers: {
        "X-CSRF-Token": token
      },
    })
    const data = await response.json()
    console.log(data)
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

    <form onSubmit={handleFileSubmit}>
      <label>Choose PDF:
        <input
          type="file"
          accept="application/pdf"
          onChange={handleFileUpload}
        />
      </label>
      <input type="submit" />
    </form>


  </div>);
};

document.addEventListener("DOMContentLoaded", () => {
  const rootEl = document.getElementById("root");
  ReactDOM.render(<App />, rootEl);
});
