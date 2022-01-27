const Main = (props) => {
  return (
    <main>
      <div className="container py-4">
        <div className="row align-items-md-stretch">
          {props.freelancers.map((freelancer) => (
            <div className="col-md-6">
              <div className="h-100 p-5 text-white bg-dark rounded-3">
                <img
                  style={{
                    width: "100px",
                    height: "100px",
                    borderRadius: "50%",
                    objectFit: "cover",
                  }}
                  src={freelancer.imageUrl}
                  alt=""
                  className=""
                />
                <h2>{freelancer.name}</h2>
                <small>By: {freelancer.owner}</small>
                <p>
                  <br />
                  <strong>Job description: </strong>
                  {freelancer.jobDescription}
                </p>
                {!freelancer.isHired ? (
                  <button
                    onClick={() =>
                      props.hireFreelancer(freelancer.index, freelancer.amount)
                    }
                    className="btn btn-outline-light"
                    type="button"
                  >
                    Hire Freelancer for {freelancer.amount / 10 ** 18} cUSD
                  </button>
                ) : (
                  <button
                  disabled
                    onClick={() =>
                      props.hireFreelancer(freelancer.index, freelancer.amount)
                    }
                    className="btn btn-outline-light"
                    type="button"
                  >
                   Hired
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </main>
  );
};

export default Main;
