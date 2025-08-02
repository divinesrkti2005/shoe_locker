const chai = require("chai");
const chaiHttp = require("chai-http");
const server = require("../server");
const Customer = require("../models/Customer");
const mongoose = require("mongoose");

const { expect } = chai;
chai.use(chaiHttp);

let adminToken;
let customerToken;
let customerId;

describe("Customer API Tests", function () {
    before(async function () {
        await Customer.deleteMany(); // Clear test database before running tests
    });

    // Register a new customer
    it("should register a new customer", function (done) {
        chai.request(server)
            .post("/api/v1/customers/register")
            .send({
                fname: "John",
                lname: "Doe",
                phone: "1234567890",
                email: "johndoe@example.com",
                password: "password123",
                role: "customer",
            })
            .end((err, res) => {
                expect(res).to.have.status(201);
                expect(res.body).to.have.property("success", true);
                done();
            });
    });

    // Login as customer
    it("should login customer and return token", function (done) {
        chai.request(server)
            .post("/api/v1/customers/login")
            .send({
                email: "johndoe@example.com",
                password: "password123",
            })
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.have.property("success", true);
                expect(res.body).to.have.property("token");
                customerToken = res.body.token;
                done();
            });
    });

    // Get all customers (should fail because only admins can access)
    it("should not allow non-admin to get all customers", function (done) {
        chai.request(server)
            .get("/api/v1/customers")
            .set("Authorization", `Bearer ${customerToken}`)
            .end((err, res) => {
                expect(res).to.have.status(403);
                expect(res.body).to.have.property("message", "Access denied. Admins only.");
                done();
            });
    });

    // Admin login to get admin token
    it("should login as admin and return token", function (done) {
        chai.request(server)
            .post("/api/v1/customers/login")
            .send({
                email: "admin@example.com",
                password: "adminpassword",
            })
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.have.property("success", true);
                expect(res.body).to.have.property("token");
                adminToken = res.body.token;
                done();
            });
    });

    // Get all customers as admin
    it("should allow admin to get all customers", function (done) {
        chai.request(server)
            .get("/api/v1/customers")
            .set("Authorization", `Bearer ${adminToken}`)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.have.property("success", true);
                expect(res.body).to.have.property("count");
                done();
            });
    });

    // Update customer profile (customer updates their own profile)
    it("should update customer profile", function (done) {
        chai.request(server)
            .put(`/api/v1/customers/update/${customerId}`)
            .set("Authorization", `Bearer ${customerToken}`)
            .send({ fname: "John Updated", lname: "Doe Updated" })
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.have.property("success", true);
                expect(res.body.data.fname).to.equal("John Updated");
                done();
            });
    });

    // Admin deletes a customer
    it("should delete a customer as admin", function (done) {
        chai.request(server)
            .delete(`/api/v1/customers/${customerId}`)
            .set("Authorization", `Bearer ${adminToken}`)
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.have.property("success", true);
                done();
            });
    });

    after(async function () {
        await mongoose.connection.close(); // Close DB connection after tests
    });
});
