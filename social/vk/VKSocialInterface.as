package social.vk
{	
		
	
	
	
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import social.SocialInterface;
	import social.common.ResourceType;
	import social.common.user.SocialUser;
	import social.events.SocialInterfaceEvent;
	import social.utils.MD5;
	import social.vkontakte.data.*;
	import social.vkontakte.transport.*;
	import social.vkontakte.utils.VKSerialization;
	import social.vkontakte.utils.VKUtil;
	import social.vkontakte.utils.uploader.VKWallUploader;
	import social.vkontakte.utils.uploader.VKWallUploaderEvent;
	import social.vkontakte.wrapper.*;
	
	import vk.APIConnection;
	
public class VKSocialInterface extends SocialInterface 
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------  
	
	private var vkApi:VKApi;
	private var apiConnecton:APIConnection;
	
	private var user:SocialUser;
	private var friends:Array;
	private var friendsWithApplication:Array;
	private var friendsWithoutApplication:Array;
	
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------      
   	public function VKSocialInterface(parameters:Object)
   	{
		resource = ResourceType.VK
		inited = true;	
		friends = new Array();
		friendsWithApplication = new Array();
		friendsWithoutApplication = new Array();
		
		apiConnecton = new APIConnection(parameters)
		vkApi = new VKApi(apiConnecton)
		vkApi.applicationSettings = new VKApplicationData(parameters);
		dispatchEvent(new SocialInterfaceEvent(SocialInterfaceEvent.INTERFACE_INITED));
   	}
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------
	
	
	override public function loginUser():void
	{	
				
		loadVKUser();
	}
	
	override public function showUserPage(user:SocialUser):void
	{
		navigateToURL(new URLRequest('http://vk.com/id'+user.id));
		
	}
	
	override public function getUsersProfiles(uids:Array, handler:Function):void
	{
		vkApi.getFullProfiles(uids.join(','),function(responce:Array):void
		{
			var socUsers:Array = []
			var serializedUsers:Array = VKSerialization.serializeUsers(responce);
			for each(var user:IVKUser in serializedUsers)
			{
				var socUser:SocialUser = new SocialUser();
				VKUtil.copyVKUserProperties(user,socUser);
				socUsers.push(socUser);
			}
			if(handler!=null)
				handler(socUsers)
		});
	}
	
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------	
	
	private function loadVKUser():void
	{
				
		var nickName:String = "nickname,";
		var nickNameIndex:int = VKTransport.FULL_USER_INFO.indexOf(nickName);
		
		var fields:String = VKTransport.FULL_USER_INFO.substring(0,nickNameIndex)+
			VKTransport.FULL_USER_INFO.substr(nickNameIndex+nickName.length);

		vkApi.getProfiles(vieverId,fields, 
			authorizeUserHandler,faultAuthorizeUserHandler);		
	}
	
	
	private function finishSocialLogin():void
	{
		var authorizeData:Object = new Object();    

		authorizeData.user = user;
		authorizeData.friends = friends;
		authorizeData.friendsWithApplication = friendsWithApplication;
		authorizeData.friendsWithoutApplication = friendsWithoutApplication;
		
		SocialInterface.instance.dispatchEvent(new SocialInterfaceEvent(SocialInterfaceEvent.LOGIN_USER,authorizeData))
	}
		
	
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------	
	private function authorizeUserHandler(responce:Array):void
	{
		var vkUser:IVKUser = VKSerialization.serializeUser(responce[0]);
		var socialUser:SocialUser = new SocialUser();
		VKUtil.copyVKUserProperties(vkUser,socialUser);
		user = socialUser;	
		vkApi.getAppFriends(appFriendsHandler,faultFriendsResponceHandler);
	}	
	
	private function appFriendsHandler(responce:Array):void
	{
		responce.push(nastiaID);
		var uids:String = responce.join();
		
		vkApi.getFullProfiles(uids,friendsProfilesHandler,faultFriendsResponceHandler);
	}
	
	private function friendsProfilesHandler(responce:Array):void
	{
		var serializedUsers:Array = VKSerialization.serializeUsers(responce);
		for each(var user:IVKUser in serializedUsers)
		{
			var socUser:SocialUser = new SocialUser();
			VKUtil.copyVKUserProperties(user,socUser);
			friendsWithApplication.push(socUser);
		}
		
		finishSocialLogin();		
	}	
	
	override public function showPaymentBox(itemInfo:Object, currency:String, handler:Function):void
	{
		ExternalInterface.addCallback("paymentComplete", function(...rest):void{
			if(handler!=null)
				handler();
		});
		ExternalInterface.call('showPaymentDialog', itemInfo.code);
	}
	
	private function faultFriendsResponceHandler(responce:VKErrorResponce):void
	{
		trace("Ошибка получения друзей ВКонтакте.");	
	}
	private function faultResponceHandler(responce:VKErrorResponce):void
	{
		trace(responce.errorMessage+" ("+responce.errorCode+")");
	}
	
	private function faultAuthorizeUserHandler(responce:VKErrorResponce):void
	{
		trace("Логин не произошел");
	}
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Photo and Wall
	//
	//--------------------------------------------------------------------------
	override public function wallPost(image:ByteArray,userId:String,text:String,callback:Function = null):void
	{
		text+=" vk.com/app4246698";
		vkApi.getWallPhotoUploadServer(userId,
			function (response:Object):void {
				var uploadUrl:String = response.upload_url;
				var uploader:VKWallUploader = new VKWallUploader(uploadUrl,vkApi,apiConnecton);
				uploader.addEventListener(VKWallUploaderEvent.POST_ERROR, onPostError,false, 0, true);
				uploader.upload(image,userId,text);
				
			},getWallPhotoUploadServerError);
	}
	
	private function onPostError(e:VKWallUploaderEvent):void
	{
		var uploader:VKWallUploader = e.target as VKWallUploader;
		showRequestBox(uploader.userId,uploader.text);
	}
	
	private function getWallPhotoUploadServerError(result:Object):void
	{
		trace("cant get wall upload server");
	}
	
	private function showRequestBox(userId:String,message:String):void
	{
		apiConnecton.callMethod('showRequestBox',userId,message);
	}
	
	override public function showInviteBox():void
	{
		apiConnecton.callMethod("showInviteBox");
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Properties
	//
	//------------------------------------------------------------------------- 
	
	override public function get errorMessageURL():String
	{
		return 'https://vk.com/topic-70282933_30078894'
	}
	
	override public function get vieverId():String
	{
		return vkApi.applicationSettings.viewerId;
	}
	
	override public function get authKey():String
	{
		return vkApi.applicationSettings.authorizeKey;
	}

	override public function get nastiaID():String
	{
		return '251475616';
	}
	
	
}
	
}