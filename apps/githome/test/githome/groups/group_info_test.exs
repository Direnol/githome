defmodule Githome.GroupInfoTest do
  use Githome.DataCase

  alias Githome.GroupInfo

  @valiad_attrs %{"name" => "my_group", "description" => "description of my group"}
  @update_attrs %{"name" => "My new name", "description" => "My new description"}
  describe "Empty groups info" do
    setup do
      Githome.Repo.delete_all(Githome.GroupInfo.Ginfo)
      :ok
    end

    test "List of GI must be empty" do
      assert [] == GroupInfo.list_ginfos()
    end

    test "Create new Group info" do
      {:ok, %{id: id}} = GroupInfo.create_ginfo(@valiad_attrs)
      assert GroupInfo.get_ginfo_by(name: @valiad_attrs["name"]).id == id
    end
  end

  describe "Test update groups info" do
    setup do
      {:ok, ginfo} = GroupInfo.create_ginfo(@valiad_attrs)
      {:ok, ginfo: ginfo}
    end

    test "Change attrs", ctx do
      {:ok, _} = GroupInfo.update_ginfo(ctx.ginfo, @update_attrs)
      assert GroupInfo.get_ginfo!(ctx.ginfo.id).name == @update_attrs["name"]
      assert GroupInfo.get_ginfo!(ctx.ginfo.id).description == @update_attrs["description"]
    end
  end
end
