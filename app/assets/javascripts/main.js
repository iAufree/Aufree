$(function() {

    //改变Sign Up 按钮的宽度
    $signup = $('.signup');
    $old_width = $signup.width();
    $signup.mouseover(function(event) {
        $signup.animate({width:'50%'}, "slow");
     }).mouseout(function(){
        $signup.animate({width:$old_width}, "slow")
     });

     //邮箱地址字体变大
    $contact = $('.contact');
     $contact.mouseover(function(event) {
        $contact.animate({fontSize:'70px'}, "slow");
     }).mouseout(function(event) {
        $contact.animate({fontSize:'30px'}, "slow");
     });; 

     //文本框focus时变高
     $textarea = $('aside').find('textarea');
     $textarea.focus(function(event) {
        $(this).animate({height:'100px'}, "normal");
     });

     //用户头像变圆
     $('.user-gravatar').find('.gravatar').mouseover(function(event) {
        $(this).animate({borderRadius:'50%'}, "slow");
     }).mouseout(function(event) {
        $(this).animate({borderRadius:'5%'}, "slow");
     });;
});