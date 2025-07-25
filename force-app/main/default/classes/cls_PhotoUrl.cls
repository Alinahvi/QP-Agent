Public class cls_PhotoUrl
{
     public string Photolink{get;set;}
     Public cls_PhotoUrl()
     {
         User u = [Select u.SmallPhotoUrl, u.FullPhotoUrl 
                     From User u where u.id=:Userinfo.getUserid()];
        //Photolink = u.FullPhotoUrl;
         Photolink='https://org62--c.na128.content.force.com/profilephoto/7293y00000044lV/F';
         
         boolean result=updateUserProfilePic('https://org62--c.na128.content.force.com/profilephoto/7293y00000044lV/F', Userinfo.getUserid(), '');
   
         System.debug('Updated -------------' + result);
     }
     
     public static Boolean updateUserProfilePic(String userProfilePicString, String userId, String fileType){
       Boolean updateSuccessful = true;

       System.debug('-------------' + userProfilePicString.length());
      try{
        //  Blob blobImage = EncodingUtil.base64Decode(userProfilePicString);
        // PageReference page = new PageReference(userProfilePicString);
        // Blob blobImage = page.getContent();
         HttpRequest req = new HttpRequest(); 
         req.setEndpoint(userProfilePicString); 
         req.setMethod('GET');
         Http binding = new Http(); 
         HttpResponse res = binding.send(req); 
          Blob blobImage = res.getBodyAsBlob();
          System.debug('Returned Body: '+res.getBody());
         ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(blobImage, 'image/jpg', 'F.jpg');
         ConnectApi.Photo photoProfile = ConnectApi.UserProfiles.setPhoto(null, userId,  fileUpload);
          
         }catch(Exception exc){
          System.debug('Exception -------------' + exc.getmessage());
         updateSuccessful = false;
         }
         
         
        return updateSuccessful;
        
   }
}