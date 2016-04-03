package social.od
{
	import api.com.odnoklassniki.Odnoklassniki;
	import api.com.odnoklassniki.events.ApiCallbackEvent;
	import api.com.odnoklassniki.events.ApiServerEvent;
	import api.com.odnoklassniki.sdk.friends.Friends;
	import api.com.odnoklassniki.sdk.stream.Stream;
	import api.com.odnoklassniki.sdk.users.Users;
	
	import core.info.bank.Currency;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	
	import social.SocialInterface;
	import social.common.ResourceType;
	import social.common.user.SocialUser;
	import social.events.SocialInterfaceEvent;
	import social.odnoklassniki.ODSerialization;
	import social.odnoklassniki.ODUser;
	import social.odnoklassniki.utils.ODUtil;
	
	public class ODSocialInterface extends SocialInterface
	{
		
		private var params:Object;
		
		private var user:SocialUser;
		private var friends:Array;
		private var friendsWithApplication:Array;
		private var friendsWithoutApplication:Array;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function ODSocialInterface(app:DisplayObject)
		{
			params = app.loaderInfo.parameters as Object
			
			friends = new Array();
			friendsWithApplication = new Array();
			friendsWithoutApplication = new Array();	
				
			resource = ResourceType.OD	
			Odnoklassniki.addEventListener(ApiServerEvent.CONNECTED, onConnect);
			Odnoklassniki.addEventListener(ApiServerEvent.CONNECTION_ERROR, onErrorConnection);
			Odnoklassniki.addEventListener(ApiServerEvent.PROXY_NOT_RESPONDING, onProxyNotRespondingError);
			Odnoklassniki.addEventListener(ApiServerEvent.NOT_YET_CONNECTED, onErrorConnection);
			Odnoklassniki.initialize(app,'')
				
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		
		private function onConnect(e:Event):void
		{
			inited = true;	
			dispatchEvent(new SocialInterfaceEvent(SocialInterfaceEvent.INTERFACE_INITED));
		}
		
		private function onErrorConnection(e:Event):void
		{
			dispatchEvent(new SocialInterfaceEvent(SocialInterfaceEvent.INTERFACE_NOT_INITED));
		}
		
		private function onProxyNotRespondingError(e:Event):void
		{
			Odnoklassniki.session.establishConnection();
		}
		
		private function getFields():Array
		{
			return ['uid','first_name','last_name','name','location','gender','birthday','age,pic_1','pic_2','pic_3']
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//--------------------------------------------------------------------------
		
		override public function loginUser():void
		{
			Users.getInfo([vieverId],getFields(),authorizeUserHandler);
		}
		
		override public function getUsersProfiles(uids:Array, handler:Function):void
		{
			Users.getInfo(uids,getFields(),function(responce:Array):void{
				var serializedUsers:Array = ODSerialization.serializeUsers(responce);
				var socUsers:Array = [];
				for each(var user:ODUser in serializedUsers)
				{
					var socUser:SocialUser = new SocialUser();
					ODUtil.copyODUserProperties(user,socUser);
					socUsers.push(socUser);
				}
				if(handler!=null)
					handler(socUsers)
			});
		}
		
		override public function wallPost(image:ByteArray, userId:String, text:String, callback:Function=null):void
		{
			if(userId!=vieverId)
			{
				ExternalInterface.call('showNotification',text,userId);
			}
			else
			{
				var attachment:Object = {"caption":"Ресторатор",media:[{"href":"link","src":"http://31.186.99.171/restaurantProdOK/128.png","type":"image"}]}
				ExternalInterface.call('publishStream',text,JSON.stringify(attachment));
			}
		}
		
		override public function showInviteBox():void
		{
			ExternalInterface.call('showInviteBox', "Давай вечером сходим в ресторан? Знаю отличное место ;)");
		}
		
		override public function showPaymentBox(itemInfo:Object,currency:String,handler:Function):void
		{
		
			ExternalInterface.addCallback("paymentComplete", function(...rest):void{
				if(handler!=null)
					handler();
			});
			ExternalInterface.call('showPaymentDialog', itemInfo.value+' '+currency ,itemInfo.code,itemInfo.price);
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Handlers
		//
		//--------------------------------------------------------------------------
		
		private function authorizeUserHandler(responce:Object):void
		{
			var odUser:ODUser = ODSerialization.serializeUser(responce[0]);
			var socialUser:SocialUser = new SocialUser();
			ODUtil.copyODUserProperties(odUser,socialUser);
			user = socialUser;	
			Friends.getAppUsers(appFriendsHandler);
		}
		
		private function appFriendsHandler(responce:Object):void
		{
			var arr:Array = responce.uids;
			arr.push(nastiaID);
			if(!arr || arr.length==0)
			{
				finishSocialLogin();
				return;
			}
			Users.getInfo(arr,getFields(),friendsProfilesHandler);
		}
		
		private function friendsProfilesHandler(responce:Array):void
		{
			var serializedUsers:Array = ODSerialization.serializeUsers(responce);
			for each(var user:ODUser in serializedUsers)
			{
				var socUser:SocialUser = new SocialUser();
				ODUtil.copyODUserProperties(user,socUser);
				friendsWithApplication.push(socUser);
			}
			finishSocialLogin();
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
		//  Public Properties
		//
		//------------------------------------------------------------------------- 
		
		override public function get nastiaID():String
		{
			return "569010575008";
		}
		
		override public function get errorMessageURL():String
		{
			return "http://www.odnoklassniki.ru/group/52255709790378/topic/62646527030698"
		}
		
		override public function get vieverId():String
		{
			return params.logged_user_id;
		}
		
		override public function get authKey():String
		{
			return params.auth_key;
		}
	
	}
}