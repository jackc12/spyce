Mix.install([
  {:ecto, "~> 3.11"}
])

defmodule API do
  # unfortunately didn't save the actual payload from the meeting so this is just from memory
  # will use quantity to derermine how many meals to actually create
  # e.g. quantity: 2 would translate to orders.meals -> [%Meal{}, %Meal{}]
  # I just did this to simplify schema design
  # not sure if there is an advantage to saving quantity
  # advantages I could think of were brevity in the json payload
  # maybe there is an advantage to creating the same meal consecutively for the robot
  # thinking something like how cpus use branch prediction
  # maybe there is some advantage to preparing meals in some certain order
  # honestly that make me lean towards the approach I went with
  # it's doubtful the external service (e.g. grubhub) would or should know if there is some preferable order to the meal preparation.
  # just having one meal per job instead of using quantities gives us an advantage because we can just sort all our meals by a key in our schema
  # say order 1 contains 2 casseroles and a pizza
  # then order 2 contains 1 casserole and a pizza
  # if we just do one meal per sob we could sort on type and just make 3 casseroles and then 1 pizza
  # again this does make a ton of assumptions about the problem that I have no evidence for but I think it is a discussion worth having
  def json(),
    do: [
      %{
        id: "123",
        external_id: "xxx456xxx",
        external_source: "grubhub",
        customer_name: "Bill Billings",
        customer_email: "bill@gmail.com",
        meals: [
          %{
            type: "casserole",
            name: "Chicken Pot Pie",
            ingredients: ["chicken", "peas", "cheese"],
            quantity: 1
          }
        ]
      }
    ]
end

defmodule Orders do
  use Ecto.Schema

  schema "orders" do
    field :order_id, :string
    field :external_id, :string
    field :external_source, :string
    has_one :customer, Customer
    has_many :meals, Meal
    timestamps()
  end
end

defmodule Customer do
  use Ecto.Schema

  schema "customers" do
    field :name, :string
    field :email, :string
  end
end

defmodule Meal do
  use Ecto.Schema

  schema "meals" do
    field :name, :string
    field :type, :string
    has_many :ingredients, Ingredient
  end
end

defmodule Ingredient do
  use Ecto.Schema

  schema "ingredients" do
    field :name, :string
    field :in_stock, :boolean
    field :temp, :float
  end
end
