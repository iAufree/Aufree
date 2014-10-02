
require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)     { 'Aufree' }
    let(:page_title)  { '' }

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "follower/following counts" do
        let(:other_user)  { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("关注 0",  href: following_user_path(user)) }
        it { should have_link("粉丝 1",  href: followers_user_path(user)) }
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading)     { '帮助' }
    let(:page_title)  { 'Help' }
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)     { '关于我' }
    let(:page_title)  { 'About Us' }
    it { should have_selector('h1',text:'关于我') }
  end

  describe "Contact page" do
    before { visit contact_path }

    it { should have_selector('h1', text:'联系') }
    it { should have_title(full_title('Contact')) }
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "关于"
    expect(page).to have_title(full_title('About Us'))
    click_link "联系"
    expect(page).to have_title(full_title('Contact'))
    click_link "帮助"
    expect(page).to have_title(full_title('Help'))
    click_link "主页"
    click_link "现在注册"
    expect(page).to have_title(full_title('Sign up'))
    click_link "Aufree"
    expect(page).to have_title(full_title(''))
  end
end