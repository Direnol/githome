defmodule Githome.SettingsTest do
  use Githome.DataCase

  alias Githome.Settings

  describe "settings" do
    alias Githome.Settings.Parameter

    @valid_attrs %{key: "some key", value: "some value"}
    @update_attrs %{key: "some updated key", value: "some updated value"}
    @invalid_attrs %{key: nil, value: nil}

    def parameter_fixture(attrs \\ %{}) do
      {:ok, parameter} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_parameter()

      parameter
    end

    test "list_settings/0 returns all settings" do
      parameter = parameter_fixture()
      assert Settings.list_settings() == [parameter]
    end

    test "get_parameter!/1 returns the parameter with given id" do
      parameter = parameter_fixture()
      assert Settings.get_parameter!(parameter.id) == parameter
    end

    test "create_parameter/1 with valid data creates a parameter" do
      assert {:ok, %Parameter{} = parameter} = Settings.create_parameter(@valid_attrs)
      assert parameter.key == "some key"
      assert parameter.value == "some value"
    end

    test "create_parameter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_parameter(@invalid_attrs)
    end

    test "update_parameter/2 with valid data updates the parameter" do
      parameter = parameter_fixture()

      assert {:ok, %Parameter{} = parameter} = Settings.update_parameter(parameter, @update_attrs)

      assert parameter.key == "some updated key"
      assert parameter.value == "some updated value"
    end

    test "update_parameter/2 with invalid data returns error changeset" do
      parameter = parameter_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_parameter(parameter, @invalid_attrs)
      assert parameter == Settings.get_parameter!(parameter.id)
    end

    test "delete_parameter/1 deletes the parameter" do
      parameter = parameter_fixture()
      assert {:ok, %Parameter{}} = Settings.delete_parameter(parameter)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_parameter!(parameter.id) end
    end

    test "change_parameter/1 returns a parameter changeset" do
      parameter = parameter_fixture()
      assert %Ecto.Changeset{} = Settings.change_parameter(parameter)
    end
  end
end
