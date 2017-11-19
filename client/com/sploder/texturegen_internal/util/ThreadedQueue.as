package com.sploder.texturegen_internal.util
{
	import com.sploder.util.ObjectEvent;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	public class ThreadedQueue extends EventDispatcher
	{
		
		public static const EVENT_QUEUED:String = "threadedqueue_queued";
		public static const EVENT_WORKING:String = "threadedqueue_working";
		public static const EVENT_CHANGE:String = "threadedqueue_change";
		public static const EVENT_COMPLETE:String = "threadedqueue_complete";
		public static const EVENT_QUEUE_EMPTY:String = "threadedqueue_queue_empty";
		
		public static var mainStage:Stage;
		
		public var persistent:Boolean;
		public var percentComplete:Number;
		public var busy:Boolean;
		protected var _completedRequests:int;
		protected var _waitingRequests:int;
		protected var _lastTaskTime:int;
		protected var _listening:Boolean;
		protected var _requestObjects:Array;
		public var pauseInterval:int;
		public var tasksPerFrame:int = 1;
		
		public function ThreadedQueue():void
		{
			super();
		}
		
		public function init():*
		{
			clearQueue();
			_listening = false;
			_lastTaskTime = 0;
			percentComplete = 1.0;
			pauseInterval = 10;
			return this;
		}
		
		
		protected function setPercentComplete(val:Number):void
		{
			if (val != percentComplete)
			{
				percentComplete = val;
				dispatchEvent(new ObjectEvent(ThreadedQueue.EVENT_CHANGE, false, false, this));
			}
		}
		
		protected function onQueueEmpty():void
		{
			if (_requestObjects != null && _waitingRequests == 0)
			{
				busy = false;
				_completedRequests = 0;
				setPercentComplete(1.0);
				dispatchEvent(new ObjectEvent(ThreadedQueue.EVENT_QUEUE_EMPTY, false, false, this));
			}
		}
		
		protected function onTaskComplete(obj:*, message:String = null):void
		{
			_completedRequests++;
			setPercentComplete(_waitingRequests / (_waitingRequests + _completedRequests));
		}
		
		protected function clearQueue():void
		{
			_requestObjects = [];
			_waitingRequests = _completedRequests = 0;
		}
		
		protected function doTask(obj:*):Boolean
		{
			if (obj != null)
				return true;
			return false;
		}
		
		protected function handleRequest(obj:*):void
		{
			if (_waitingRequests > 0)
				_waitingRequests--;
			dispatchEvent(new ObjectEvent(ThreadedQueue.EVENT_WORKING, false, false, obj));
			doTask(obj);
			_lastTaskTime = getTimer();
			onTaskComplete(obj);
			dispatchEvent(new ObjectEvent(ThreadedQueue.EVENT_COMPLETE, false, false, obj));
		}
		
		protected function checkQueue(e:Event = null):void
		{
			if (_requestObjects == null)
				return;
			if (getTimer() - _lastTaskTime < pauseInterval)
				return;
			for (var i:int = 0; i < tasksPerFrame; i++)
			{
				if (_requestObjects.length > 0)
					handleRequest(_requestObjects.shift());
				else
					stopListening();
				if (_waitingRequests == 0)
					onQueueEmpty();
			}
		}
		
		protected function checkThread():void
		{
			checkQueue();
		}
		
		public function queueObject(obj:*):void
		{
			_waitingRequests++;
			_requestObjects.push(obj);
			busy = true;
			if (!_listening)
				startListening();
			dispatchEvent(new ObjectEvent(ThreadedQueue.EVENT_QUEUED, false, false, obj));
		}
		
		protected function stopListening():void
		{
			if (mainStage == null)
				throw new Error("You must register the stage with ThreadedQueue.mainStage");
			mainStage.removeEventListener(Event.ENTER_FRAME, checkQueue);
			_listening = false;
		}
		
		protected function startListening():void
		{
			if (mainStage == null)
				throw new Error("You must register the stage with ThreadedQueue.mainStage");
			mainStage.addEventListener(Event.ENTER_FRAME, checkQueue);
			_listening = true;
		}
		
		public function destroy():void
		{
			stopListening();
			_requestObjects = null;
		}	
	}
}
