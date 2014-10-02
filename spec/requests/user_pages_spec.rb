require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "index" do

    let(:user) {FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('所有用户') }

    describe "pagination" do

      before(:all)  { 30.times { FactoryGirl.create(:user) } }
      after(:all)   { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
  
      it { should_not have_link('X') }
  
      describe "as an admin usre" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end
        
        it { should have_link('X',   href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('X',  match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('X', href: user_path(admin)) }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button "关注"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "关注"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "关注" }
          it { should have_xpath("//input[@value='取消']") }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "取消"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "取消"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "取消" }
          it { should have_xpath("//input[@value='关注']") }
        end
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('注册') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "完成注册" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('错误') }
      end
    end

    describe "with valid information" do
      before do
        fill_in "用户名",         with: "Example User"
        fill_in "邮箱",        with: "user@example.com"
        fill_in "密码",     with: "foobar"
        fill_in "确认密码", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email:"user@example.com") }

        it { should have_link('退出') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text:'欢迎') }
     end
   end
 end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
     visit edit_user_path(user)
   end

    describe "page" do
      it { should have_content("更新资料") }
      it { should have_title("Edit user") }
      it { should have_link('更改头像',  href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "保存" }

      it { should have_content('错误') }
    end

    describe "with valid information" do
      let(:new_name)    { "New Name" }
      let(:new_email)   { "new@example.com" }
      before do
        fill_in "用户名",               with: new_name
        fill_in "邮箱",              with: new_email
        fill_in "密码",           with: user.password
        fill_in "确认密码",   with: user.password   
        click_button "保存"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('退出', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before { patch user_path(user), params }
      specify { expect(user.reload).not_to be_admin }
    end
  end

  describe "following/followers" do
    let(:user)  { FactoryGirl.create(:user) }
    let(:other_user)  { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title(full_title('关注')) }
      it { should have_selector('h3', text: '关注') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title(full_title('粉丝')) }
      it { should have_selector('h3', text: '粉丝') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end