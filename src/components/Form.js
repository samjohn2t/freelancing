import { useState } from "react";

const Form = (props) => {
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [image, setImage] = useState("");
  const [amount, setAmount] = useState("");

  const handleSubmit = (event) => {
    event.preventDefault();
    console.log(name, description, image, amount);
    props.addFreelancer(name, description, image, amount)
    setName("");
    setDescription("");
    setImage("");
    setAmount("");
  };

  return (
    <div className="container py-4">
      <h2>Add your Job Description</h2>
      <form onSubmit={handleSubmit}>
        <div className="mb-3">
          <label className="form-label">Job Name</label>
          <input type="text" className="form-control" onChange={(e) => setName(e.target.value)} required/>
        </div>
        <div className="mb-3">
          <label htmlFor="exampleInputEmail1" className="form-label">
            Job Description
          </label>
          <input
            type="text"
            className="form-control"
            onChange={(e) => setDescription(e.target.value)}
            required
          />
        </div>
        <div className="mb-3">
          <label htmlFor="exampleInputEmail1" className="form-label">
            Image of Freelancer
          </label>
          <input
            type="text"
            className="form-control"
            onChange={(e) => setImage(e.target.value)}
            required
          />
        </div>
        <div className="mb-3">
          <label htmlFor="exampleInputEmail1" className="form-label">
            Amount to be Paid
          </label>
          <input
            type="text"
            className="form-control"
            onChange={(e) => setAmount(e.target.value)}
            required
          />
        </div>
        <button type="submit" className="btn btn-primary">
          Submit
        </button>
      </form>
      <footer className="pt-3 mt-4 text-muted border-top">© 2022</footer>
    </div>
  );
};
export default Form;
