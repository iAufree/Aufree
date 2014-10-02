require 'spec_helper'

describe "Authentication" do
  
  subject { page }

  describe "signin page" do
  	before { visit signin_path }
 
  	it { should have_content('登录') }
  	it { should have_title('Sign in') }
  end

  describe "signin" do
  	before { visit signin_path }

  	describe "with invalid information" do
  	  before { click_button "登录" }

  	  it { should have_title('Sign in') }
  	  it { should have_selector('div.alert.alert-error') }

  	  describe "after visiting another page" do
  	  	before { click_link "主页" }
  	  	it { should_not have_selector('div.alert.alert-errors') }
  	  end
  	end

  	describe "with valid information" do
  		let(:user)  { FactoryGirl.create(:user) }
  		before { sign_in user }

  		it { should have_title(user.name) }
      it { should have_link('用户',        href: users_path) }
  		it { should have_link('资料',		  href: user_path(user)) }
      it { should have_link('设置',     href: edit_user_path(user)) }
  		it { should have_link('退出',	  	href: signout_path) }
  		it { should_not have_link('登录',	 href: signin_path) }

  		describe "followed by singout" do
  			before { click_link "退出" }
  			it { should have_link('登录') }
        it { should_not have_link('资料',    href:user_path(user)) }
        it { should_not have_link('设置',    href:edit_user_path(user)) }
  		end
  	end
  end

  describe "authentication" do
    
    describe "for not-signed-in users" do
      let(:user)  { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "邮箱",    with: user.email
          fill_in "密码", with: user.password
          click_button "登录"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end

          describe "when signing in again" do
            before do
              click_link '退出'
              visit signin_path
              fill_in "邮箱",    with: user.email
              fill_in "密码", with: user.password
              click_button "登录"
            end

            it "should render the default (profile) page" do
              expect(page).to have_title(user.name)
            end
          end
        end
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "visiting the following page" do
          before  { visit followers_user_path(user) }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
    
    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end
  end
end

