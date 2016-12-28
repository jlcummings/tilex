defmodule DeveloperCreatesPostTest do
  use Tilex.IntegrationCase, async: true

  alias Tilex.Post

  test "fills out form and submits", %{session: session} do

    EctoFactory.insert(:channel, name: "phoenix", twitter_hashtag: "phoenix")

    visit(session, "/posts/new")
    h1_heading = get_text(session, "main header h1")
    assert h1_heading == "Create Post"

    fill_in(session, "Title", with: "Example Title")
    fill_in(session, "Body", with: "Example Body")
    Wallaby.DSL.Actions.select(session, "Channel", option: "phoenix")
    click_on(session, 'Submit')

    post = Enum.reverse(Tilex.Repo.all(Post)) |> hd
    assert post.body == "Example Body"
    assert post.title == "Example Title"

    index_h1_heading = get_text(session, "header.site_head div h1")
    page_body        = get_text(session, "body")
    post_footer      = get_text(session, ".post aside")

    assert index_h1_heading =~ ~r/Today I Learned/i
    assert page_body        =~ ~r/Example Title/
    assert page_body        =~ ~r/Example Body/
    assert post_footer      =~ ~r/#phoenix/i
  end

  test "cancels submission", %{session: session} do

    visit(session, "/posts/new")
    click_link(session, "cancel")
    path = get_current_path(session)

    assert path == "/"
  end

  test "fails to enter things", %{session: session} do

    visit(session, "/posts/new")
    click_on(session, 'Submit')

    body = get_text(session, "body")

    assert body =~ ~r/Title can't be blank/
    assert body =~ ~r/Body can't be blank/
    assert body =~ ~r/Channel can't be blank/
  end

  test "enters a title that is too long", %{session: session} do

    visit(session, "/posts/new")
    fill_in(session, "Title", with: String.duplicate("I can codez ", 10))
    click_on(session, 'Submit')

    body = get_text(session, "body")

    assert body =~ ~r/Title should be at most 50 character/
  end
end
