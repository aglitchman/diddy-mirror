Strict

Import assert

#Rem
header: Monkey Collections Framework
Based loosely on the Java Collections Framework
#End

'''' Top level Collection stuff ''''

#Rem
	Summary: ICollection
	Due to limitations with generics in Monkey, ToArray cannot work with an array of type E.  We must return Object[] instead.
	(Note: I believe this limitation has been removed as of Monkey v47, but it will remain for now.)
#End
Class ICollection<E> Abstract
Private
	' A custom comparator to use for sorting and comparing items.
	Field comparator:IComparator = Null
	
Public
' Abstract
	Method Add:Bool(o:E) Abstract
	Method AddAll:Bool(c:ICollection<E>) Abstract
	Method Clear:Void() Abstract
	Method Contains:Bool(o:E) Abstract
	Method ContainsAll:Bool(c:ICollection<E>) Abstract
	Method Enumerator:IEnumerator<E>() Abstract ' should return an appropriate IEnumerator for the collection
	Method FillArray:Int(arr:Object[]) Abstract ' populates the passed array and returns the number of items filled. best used for android
	Method IsEmpty:Bool() Abstract
	Method Remove:Bool(o:E) Abstract
	Method RemoveAll:Bool(c:ICollection<E>) Abstract
	Method RetainAll:Bool(c:ICollection<E>) Abstract
	Method Size:Int() Property Abstract
	Method Sort:Void(reverse:Bool = False, comp:IComparator = Null) Abstract
	Method ToArray:Object[]() Abstract ' creates a new array of the correct size and returns it

' Methods
	'summary: due to a limitation in Monkey regarding ObjectEnumerator and inheritance, this simply calls Enumerator()
	Method ObjectEnumerator:IEnumerator<E>()
		Return Enumerator()
	End
	
' Properties
	'summary: Property to read comparator
	Method Comparator:IComparator() Property
		Return comparator
	End
	
	'summary: Property to write comparator
	Method Comparator:Void(comparator:IComparator) Property
		Self.comparator = comparator
	End
End



#Rem
	summary: IEnumerator
	Used in the ObjectEnumerator method for calls to EachIn.
	If retrieved and used manually, the HasPrevious/PreviousObject/Remove/First/Last methods can be called.
#End
Class IEnumerator<E>
' Abstract
	Method HasNext:Bool() Abstract
	Method HasPrevious:Bool() Abstract
	Method NextObject:E() Abstract
	Method PreviousObject:E() Abstract
	Method Remove:Void() Abstract
	Method First:Void() Abstract
	Method Last:Void() Abstract
	Method Reset:Void() Abstract
End



#Rem
	summary: IComparable
	Allows developers to sort a collection without using a Comparator.  Each class is responsible
	for providing its own logic to determine how it should be sorted.
#End
Interface IComparable
	Method Compare:Int(o:Object)
	Method Equals:Bool(o:Object)
End



#Rem
	summary:IComparator
	This is a way For developers To provide a custom comparison Method For sorting lists.
	It's sort of like a function pointer.
#End
Class IComparator Abstract
' Abstract
	Method Compare:Int(o1:Object, o2:Object) Abstract
	
' Methods
	Method Equals:Bool(o1:Object, o2:Object)
		Return o1 = o2 Or Compare(o1, o2) = 0
	End
	
	Method HashCode:Int(o:Object)
		Return 0
	End
End

#Rem
	summary: DefaultComparator
	Implements an IComparator to handle primitive wrappers and strings.
#End
Global DEFAULT_COMPARATOR:DefaultComparator = New DefaultComparator
Class DefaultComparator Extends IComparator
' Methods
	'summary: Overrides IComparator
	Method Compare:Int(o1:Object, o2:Object)
		If IntObject(o1) <> Null And IntObject(o2) <> Null Then
			If IntObject(o1).value < IntObject(o2).value Then Return -1
			If IntObject(o1).value > IntObject(o2).value Then Return 1
			Return 0
		ElseIf FloatObject(o1) <> Null And FloatObject(o2) <> Null Then
			If FloatObject(o1).value < FloatObject(o2).value Then Return -1
			If FloatObject(o1).value > FloatObject(o2).value Then Return 1
			Return 0
		ElseIf StringObject(o1) <> Null And StringObject(o2) <> Null Then
			If StringObject(o1).value < StringObject(o2).value Then Return -1
			If StringObject(o1).value > StringObject(o2).value Then Return 1
			Return 0
		End
		If o1 = o2 Then Return 0
		If o1 = Null Then Return -1
		If o2 = Null Then Return 1
		Return 0 ' don't know what to do!
	End
	
	'summary: Overrides IComparator
	Method Equals:Bool(o1:Object, o2:Object)
		If IntObject(o1) <> Null And IntObject(o2) <> Null Then
			Return IntObject(o1).value = IntObject(o2).value
		ElseIf FloatObject(o1) <> Null And FloatObject(o2) <> Null Then
			Return FloatObject(o1).value = FloatObject(o2).value
		ElseIf StringObject(o1) <> Null And StringObject(o2) <> Null Then
			Return StringObject(o1).value = StringObject(o2).value
		End
		Return o1 = o2
	End
End




'''' List stuff ''''

#Rem
	summary: IList
	Extends ICollection to implement some of the abstract methods that apply to any kind of list.
#End
Class IList<E> Extends ICollection<E> Abstract
Private
	' If true, bounds checking should be performed.
#if CONFIG="debug"
	Field rangeChecking:Bool = True
#else
	Field rangeChecking:Bool = False
#end
	
	'summary: A counter for modifications to the list.  Used for concurrency checks.
	Field modCount:Int = 0
	
	'summary: Performs a range check.
	Method RangeCheck:Void(index:Int)
		Local size:Int = Self.Size()
		' range check doesn't use assert, for speed
		If index < 0 Or index >= size Then Throw New IndexOutOfBoundsException("IList.RangeCheck: Index out of bounds: " + index + " is not 0<=index<" + size)
	End
	
Public
' Abstract
	Method AddLast:Bool(o:E) Abstract
	Method RemoveLast:E() Abstract
	Method GetLast:E() Abstract
	Method AddFirst:Bool(o:E) Abstract
	Method RemoveFirst:E() Abstract
	Method GetFirst:E() Abstract
	Method Get:E(index:Int) Abstract
	Method Insert:Void(index:Int, o:E) Abstract
	Method InsertAll:Bool(index:Int, c:ICollection<E>) Abstract
	Method IndexOf:Int(o:E) Abstract
	Method LastIndexOf:Int(o:E) Abstract
	Method RemoveAt:E(index:Int) Abstract ' Can't overload Remove since it's an inherited method, and Monkey doesn't support that.
	Method RemoveRange:Void(fromIndex:Int, toIndex:Int) Abstract
	Method Set:E(index:Int, o:E) Abstract
	
' Methods
	'summary: Overrides ICollection
	Method Enumerator:IEnumerator<E>()
		Return New ListEnumerator<E>(Self)
	End
	
' Properties
	'summary: Property to read rangeChecking
	Method RangeChecking:Bool() Property
		Return rangeChecking
	End
	
	'summary: Property to write rangeChecking
	Method RangeChecking:Void(rangeChecking:Bool) Property
		Self.rangeChecking = rangeChecking
	End
End



#Rem
	summary: ListEnumerator
	Extends IEnumerator to provide support for EachIn.  Blocks concurrent modification, but allows elements to be removed on the fly.
#End
Class ListEnumerator<E> Extends IEnumerator<E>
Private
	Field lst:IList<E>
	Field lastIndex:Int = 0
	Field index:Int = 0
	Field expectedModCount:Int = 0
	
	Method CheckConcurrency:Void()
		' for speed we don't use assert
		If lst.modCount <> expectedModCount Then Throw New ConcurrentModificationException("ListEnumerator.CheckConcurrency: Concurrent list modification")
	End

Public
' Constructors
	Method New(lst:IList<E>)
		Self.lst = lst
		expectedModCount = lst.modCount
	End

' Methods
	'summary: Overrides IEnumerator
	Method HasNext:Bool()
		CheckConcurrency()
		Return index < lst.Size
	End
	
	'summary: Overrides IEnumerator
	Method HasPrevious:Bool()
		CheckConcurrency()
		Return index > 0
	End
	
	'summary: Overrides IEnumerator
	Method NextObject:E()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return lst.Get(lastIndex)
	End
	
	'summary: Overrides IEnumerator
	Method PreviousObject:E()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return lst.Get(lastIndex)
	End
	
	'summary: Overrides IEnumerator
	Method Remove:Void()
		CheckConcurrency()
		lst.RemoveAt(lastIndex)
		If lastIndex < index Then index -= 1
		lastIndex = -1
		expectedModCount = lst.modCount
	End
	
	'summary: Overrides IEnumerator
	Method First:Void()
		CheckConcurrency()
		index = 0
	End
	
	'summary: Overrides IEnumerator
	Method Last:Void()
		CheckConcurrency()
		index = lst.Size
	End
	
	'summary: Overrides IEnumerator
	Method Reset:Void()
		index = 0
		expectedModCount = lst.modCount
	End
End

#Rem
	summary: ArrayListEnumerator
	Extends ListEnumerator to avoid some method calls.
#End
Class ArrayListEnumerator<E> Extends ListEnumerator<E>
Private
	Field alst:ArrayList<E>

Public
' Constructors
	Method New(lst:ArrayList<E>)
		Super.New(lst)
		Self.alst = lst
		expectedModCount = alst.modCount
	End
	
' Methods
	'summary: Overrides ListEnumerator
	Method HasNext:Bool()
		CheckConcurrency()
		Return index < alst.size
	End
	
	'summary: Overrides ListEnumerator
	Method NextObject:E()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return E(alst.elements[lastIndex])
	End
	
	'summary: Overrides ListEnumerator
	Method PreviousObject:E()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return E(alst.elements[lastIndex])
	End
End

Class IntListEnumerator Extends ListEnumerator<IntObject>
' Constructors
	Method New(lst:IList<IntObject>)
		Super.New(lst)
	End

' Methods
	Method NextInt:Int()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return lst.Get(lastIndex).value
	End

	Method PreviousInt:Int()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return lst.Get(lastIndex).value
	End
End

Class FloatListEnumerator Extends ListEnumerator<FloatObject>
' Constructors
	Method New(lst:IList<FloatObject>)
		Super.New(lst)
	End

' Methods
	Method NextFloat:Float()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return lst.Get(lastIndex).value
	End
	
	Method PreviousFloat:Float()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return lst.Get(lastIndex).value
	End
End

Class StringListEnumerator Extends ListEnumerator<StringObject>
' Constructors
	Method New(lst:IList<StringObject>)
		Super.New(lst)
	End

' Methods
	Method NextString:String()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return lst.Get(lastIndex).value
	End
	
	Method PreviousString:String()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return lst.Get(lastIndex).value
	End
End

#Rem
	summary: ArrayList
	Concrete implementation of IList that uses a dynamically sized array to store elements.
	Has best performance when it is initialised with a capacity large enough to hold the expected number of elements.
#End
Class ArrayList<E> Extends IList<E>
Private
	' fields
	Field elements:Object[]
	Field size:Int = 0

	'summary: resizes the elements array if necessary to ensure it can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			modCount += 1
		End
	End
	
	Method RangeCheck:Void(index:Int)
		' range check doesn't use assert, for speed
		If index < 0 Or index >= size Then Throw New IndexOutOfBoundsException("ArrayList.RangeCheck: Index out of bounds: " + index + " is not 0<=index<" + size)
	End

	Field tempArr:Object[] = New Object[128] ' temp array used for internal call to ToArray (so we don't create an object)
	
Public
' Constructors
	Method New()
		Self.elements = New Object[10]
	End

	Method New(initialCapacity:Int)
		AssertGreaterThanOrEqualInt(initialCapacity, 0, "ArrayList.New: Illegal Capacity:")
		Self.elements = New Object[initialCapacity]
	End

	Method New(c:ICollection<E>)
		elements = c.ToArray()
		size = elements.Length
	End

' Methods
	'summary: Overrides ICollection
	Method Add:Bool(o:E)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		elements[size] = o
		size+=1
		modCount += 1
		Return True
	End
	
	'summary: Overrides ICollection
	Method AddAll:Bool(c:ICollection<E>)
		If c.IsEmpty() Then Return False
		Local newItemCount:Int = c.Size
		If size + newItemCount > elements.Length Then EnsureCapacity(size+newItemCount)
		If tempArr.Length < newItemCount Then tempArr = tempArr.Resize(newItemCount)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = 0 Until len
			elements[size] = tempArr[i]
			size+=1
		End
		modCount += 1
		Return newItemCount <> 0
	End
	
	'summary: Overrides ICollection
	Method Clear:Void()
		For Local i:Int = 0 Until size
			elements[i] = Null
		Next
		modCount += 1
		size = 0
	End
	
	'summary: Overrides ICollection
	Method Contains:Bool(o:E)
		For Local i:Int = 0 Until size
			If elements[i] = o Then Return True
		Next
		Return False
	End
	
	'summary: Overrides ICollection
	Method ContainsAll:Bool(c:ICollection<E>)
		If c.IsEmpty() Then Return True
		If tempArr.Length < c.Size Then tempArr = tempArr.Resize(c.Size)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = 0 Until len
			If Not Self.Contains(E(tempArr[i])) Then Return False
		Next
		Return True
	End
	
	'summary: Overrides ICollection
	Method Enumerator:IEnumerator<E>()
		Return New ArrayListEnumerator<E>(Self)
	End
	
	'summary: Overrides ICollection
	Method FillArray:Int(arr:Object[])
		AssertGreaterThanOrEqualInt(arr.Length, size, "ArrayList.FillArray: Array too small:")
		For Local i:Int = 0 Until size
			arr[i] = elements[i]
		Next
		Return size
	End
	
	'summary: Overrides ICollection
	Method IsEmpty:Bool()
		Return size = 0
	End
	
	'summary: Overrides ICollection
	Method Remove:Bool(o:E)
		For Local i:Int = 0 Until size
			If elements[i] = o Then
				RemoveAt(i)
				modCount += 1
				Return True
			End
		Next
		Return False
	End
	
	'summary: Overrides ICollection
	Method RemoveAll:Bool(c:ICollection<E>)
		If c.IsEmpty() Then Return False
		Local modified:Bool = False
		If tempArr.Length < c.Size Then tempArr = tempArr.Resize(c.Size)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = 0 Until len
			If Self.Contains(E(tempArr[i])) Then
				Self.Remove(E(tempArr[i]))
			End
		Next
		If modified Then modCount += 1
		Return modified
	End
	
	'summary: Overrides ICollection
	Method RetainAll:Bool(c:ICollection<E>)
		Local modified:Bool = False
		If tempArr.Length < c.Size Then tempArr = tempArr.Resize(c.Size)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = 0 Until len
			If Not Self.Contains(E(tempArr[i])) Then
				Self.Remove(E(tempArr[i]))
				modified = True
			End
		Next
		If modified Then modCount += 1
		Return modified
	End
	
	'summary: Overrides ICollection
	Method Size:Int() Property
		Return size
	End
	
	'summary: Overrides ICollection
	Method Sort:Void(reverse:Bool = False, comp:IComparator = Null)
		If size <= 1 Then Return ' can't sort 0 or 1 elements
		If comp = Null Then comp = Self.Comparator
		If comp = Null Then comp = DEFAULT_COMPARATOR
		QuickSort(elements, 0, size-1, comp, reverse)
		modCount += 1
	End
	
	'summary: Overrides ICollection
	Method ToArray:Object[]()
		Local arr:Object[] = New Object[size]
		For Local i:Int = 0 Until size
			arr[i] = elements[i]
		Next
		Return arr
	End
	
	'summary: Overrides IList
	Method AddLast:Bool(o:E)
		Return Add(o)
	End
	
	'summary: Overrides IList
	Method RemoveLast:E()
		Return RemoveAt(size-1)
	End
	
	'summary: Overrides IList
	Method GetLast:E()
		Return Get(size-1)
	End
	
	'summary: Overrides IList
	Method AddFirst:Bool(o:E)
		Insert(0, o)
		Return True
	End
	
	'summary: Overrides IList
	Method RemoveFirst:E()
		Return RemoveAt(0)
	End
	
	'summary: Overrides IList
	Method GetFirst:E()
		Return Get(0)
	End
	
	'summary: Overrides IList
	Method Get:E(index:Int)
		If rangeChecking Then RangeCheck(index)
		Return E(elements[index])
	End
	
	'summary: Overrides IList
	Method Insert:Void(index:Int, o:E)
		If index <> size And rangeChecking Then RangeCheck(index)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		For Local i:Int = size Until index Step -1
			elements[i] = elements[i-1]
		Next
		elements[index] = o
		size+=1
		modCount += 1
	End
	
	'summary: Overrides IList
	Method InsertAll:Bool(index:Int, c:ICollection<E>)
		Local newItemCount:Int = c.Size
		If newItemCount = 0 Then Return False
		If size + newItemCount > elements.Length Then EnsureCapacity(size+newItemCount)
		If tempArr.Length < newItemCount Then tempArr = tempArr.Resize(newItemCount)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = size - 1 To index Step -1
			elements[i+newItemCount] = elements[i]
		Next
		For Local i:Int = 0 Until newItemCount
			elements[index+i] = tempArr[i]
		End
		size += newItemCount
		modCount += 1
		Return newItemCount <> 0
	End
	
	'summary: Overrides IList
	Method IndexOf:Int(o:E)
		For Local i:Int = 0 Until size
			If elements[i] = o Then Return i
		Next
		Return -1
	End
	
	'summary: Overrides IList
	Method LastIndexOf:Int(o:E)
		For Local i:Int = size-1 To 0 Step -1
			If elements[i] = o Then Return i
		Next
		Return -1
	End
	
	'summary: Overrides IList
	Method RemoveAt:E(index:Int)
		If rangeChecking Then RangeCheck(index)
		Local oldValue:E = E(elements[index])
		For Local i:Int = index Until size-1
			elements[i] = elements[i+1]
		Next
		elements[size-1] = Null
		size-=1
		modCount += 1
		Return oldValue
	End

	'summary: Overrides IList
	Method RemoveRange:Void(fromIndex:Int, toIndex:Int)
		AssertLessThanOrEqualInt(fromIndex, toIndex, "ArrayList.RemoveRange: fromIndex > toIndex:")
		If rangeChecking Then
			RangeCheck(fromIndex)
			RangeCheck(toIndex)
		End
		For Local i:Int = 0 Until toIndex - fromIndex
			RemoveAt(fromIndex)
		Next
	End
	
	'summary: Overrides IList
	Method Set:E(index:Int, o:E)
		If rangeChecking Then RangeCheck(index)
		Local oldValue:E = E(elements[index])
		elements[index] = o
		modCount += 1
		Return oldValue
	End
End




'summary: ArrayList wrapper classes
Class IntArrayList Extends ArrayList<IntObject>
' Methods
	Method AddInt:Bool(o:Int)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		elements[size] = New IntObject(o)
		size+=1
		modCount += 1
		Return True
	End
	
	Method ContainsInt:Bool(o:Int)
		For Local i:Int = 0 Until size
			If IntObject(elements[i]).value = o Then Return True
		Next
		Return False
	End
	
	'summary: Overrides ArrayList
	Method Enumerator:IEnumerator<IntObject>()
		Return New IntListEnumerator(Self)
	End
	
	Method RemoveInt:Bool(o:Int)
		For Local i:Int = 0 Until size
			If IntObject(elements[i]).value = o Then
				RemoveAt(i)
				modCount += 1
				Return True
			End
		Next
		Return False
	End
	
	Method ToIntArray:Int[]()
		Local arr:Int[] = New Int[size]
		For Local i:Int = 0 Until size
			arr[i] = IntObject(elements[i]).value
		Next
		Return arr
	End
	
	Method GetInt:Int(index:Int)
		If rangeChecking Then RangeCheck(index)
		Return IntObject(elements[index]).value
	End
	
	Method InsertInt:Void(index:Int, o:Int)
		If rangeChecking Then RangeCheck(index)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		For Local i:Int = size Until index Step -1
			elements[i] = elements[i-1]
		Next
		elements[index] = New IntObject(o)
		size+=1
		modCount += 1
	End
	
	Method IndexOfInt:Int(o:Int)
		For Local i:Int = 0 Until size
			If IntObject(elements[i]).value = o Then Return i
		Next
		Return -1
	End
	
	Method LastIndexOfInt:Int(o:E)
		For Local i:Int = size-1 To 0 Step -1
			If IntObject(elements[i]).value = o Then Return i
		Next
		Return -1
	End

	Method SetInt:Int(index:Int, o:Int)
		If rangeChecking Then RangeCheck(index)
		Local oldValue:Int = IntObject(elements[index]).value
		If elements[index] <> Null Then
			IntObject(elements[index]).value = o ' XXX: not sure whether we can change value on the fly
		End
		modCount += 1
		Return oldValue
	End

	Method FillIntArray:Int(arr:Int[])
		AssertLessThanInt(arr.Length, size, "IntArrayList.FillIntArray: Array too small:")
		For Local i:Int = 0 Until size
			arr[i] = IntObject(elements[i]).value
		Next
		Return size
	End
End
	
Class FloatArrayList Extends ArrayList<FloatObject>
' Methods
	Method AddFloat:Bool(o:Float)
		If size + 1 > elements.Length Then EnsureCapacity(size + 1)
		elements[size] = New FloatObject(o)
		size += 1
		modCount += 1
		Return True
	End
	
	Method ContainsFloat:Bool(o:Float)
		For Local i:Int = 0 Until size
			If FloatObject(elements[i]).value = o Then Return True
		Next
		Return False
	End
	
	'summary: Overrides ArrayList
	Method Enumerator:IEnumerator<FloatObject>()
		Return New FloatListEnumerator(Self)
	End
	
	Method RemoveFloat:Bool(o:Float)
		For Local i:Int = 0 Until size
			If FloatObject(elements[i]).value = o Then
				RemoveAt(i)
				modCount += 1
				Return True
			End
		Next
		Return False
	End

	Method ToFloatArray:Float[]()
		Local arr:Float[] = New Float[size]
		For Local i:Int = 0 Until size
			arr[i] = FloatObject(elements[i]).value
		Next
		Return arr
	End
	
	Method GetFloat:Float(index:Int)
		If rangeChecking Then RangeCheck(index)
		Return FloatObject(elements[index]).value
	End
	
	Method InsertFloat:Void(index:Int, o:Float)
		If rangeChecking Then RangeCheck(index)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		For Local i:Int = size Until index Step -1
			elements[i] = elements[i-1]
		Next
		elements[index] = New FloatObject(o)
		size+=1
		modCount += 1
	End
	
	Method IndexOfFloat:Int(o:Float)
		For Local i:Int = 0 Until size
			If FloatObject(elements[i]).value = o Then Return i
		Next
		Return -1
	End
	
	Method LastIndexOfFloat:Int(o:Float)
		For Local i:Int = size-1 To 0 Step -1
			If FloatObject(elements[i]).value = o Then Return i
		Next
		Return -1
	End
  
	Method SetFloat:Float(index:Int, o:Float)
		If rangeChecking Then RangeCheck(index)
		Local oldValue:Float = FloatObject(elements[index]).value
		If elements[index] <> Null Then
			FloatObject(elements[index]).value = o ' XXX: not sure whether we can change value on the fly
		End
		modCount += 1
		Return oldValue
	End
	
	Method FillFloatArray:Int(arr:Float[])
		AssertLessThanInt(arr.Length, size, "FloatArrayList.FillFloatArray: Array too small:")
		For Local i:Int = 0 Until size
			arr[i] = FloatObject(elements[i]).value
		Next
		Return size
	End
End

Class StringArrayList Extends ArrayList<StringObject>
' Methods
	Method AddString:Bool(o:String)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		elements[size] = New StringObject(o)
		size+=1
		modCount += 1
		Return True
	End
  
	Method ContainsString:Bool(o:String)
		For Local i:Int = 0 Until size
			If StringObject(elements[i]).value = o Then Return True
		Next
		Return False
	End

	'summary: Overrides ArrayList
	Method Enumerator:IEnumerator<StringObject>()
		Return New StringListEnumerator(Self)
	End
	
	Method RemoveString:Bool(o:String)
		For Local i:Int = 0 Until size
			If StringObject(elements[i]).value = o Then
				RemoveAt(i)
				modCount += 1
				Return True
			End
		Next
		Return False
	End

	Method ToStringArray:String[]()
		Local arr:String[] = New String[size]
		For Local i:Int = 0 Until size
			arr[i] = StringObject(elements[i]).value
		Next
		Return arr
	End
	
	Method GetString:String(index:Int)
		If rangeChecking Then RangeCheck(index)
		Return StringObject(elements[index]).value
	End
	
	Method InsertString:Void(index:Int, o:String)
		If rangeChecking Then RangeCheck(index)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		For Local i:Int = size Until index Step -1
			elements[i] = elements[i-1]
		Next
		elements[index] = New StringObject(o)
		size+=1
		modCount += 1
	End
	
	Method IndexOfString:Int(o:String)
		For Local i:Int = 0 Until size
			If StringObject(elements[i]).value = o Then Return i
		Next
		Return -1
	End
	
	Method LastIndexOfString:Int(o:String)
		For Local i:Int = size-1 To 0 Step -1
			If StringObject(elements[i]).value = o Then Return i
		Next
		Return -1
	End
  
	Method SetString:String(index:Int, o:String)
		If rangeChecking Then RangeCheck(index)
		Local oldValue:String = StringObject(elements[index]).value
		If elements[index] <> Null Then
			StringObject(elements[index]).value = o ' XXX: not sure whether we can change value on the fly
		End
		modCount += 1
		Return oldValue
	End

	Method FillStringArray:Int(arr:String[])
		AssertLessThanInt(arr.Length, size, "StringArrayList.FillStringArray: Array too small:")
		For Local i:Int = 0 Until size
			arr[i] = StringObject(elements[i]).value
		Next
		Return size
	End
End


'summary: SparseArray
Class SparseArray<E>
Private
	Field elements:Object[]
	Field indices:Int[]
	Field size:Int
	Field arraySize:Int
	Field defaultValue:E
	
	'summary: resizes the arrays if necessary to ensure they can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			indices = indices.Resize(newCapacity)
		End
	End
	
Public
	Method New(arraySize:Int=-1, defaultCapacity:Int=100, defaultValue:E=Null)
		AssertGreaterThanInt(defaultCapacity, 0, "Default capacity must be greater than 0!")
		elements = New Object[defaultCapacity]
		indices = New Int[defaultCapacity]
		Self.arraySize = arraySize
		Self.defaultValue = defaultValue
	End
	
	Method Size:Int() Property
		Return size
	End
	
	Method ArraySize:Int() Property
		Return arraySize
	End
	
	Method ArraySize:Void(arraySize:Int) Property
		AssertGreaterThanInt(arraySize, size, "The SparseArray contains more mappings than the requested size.")
		Self.arraySize = arraySize
	End
	
	Method DefaultValue:E() Property
		Return defaultValue
	End
	
	Method DefaultValue:Void(defaultValue:E) Property
		Self.defaultValue = defaultValue
	End
	
	Method Get:E(index:Int)
		If index < 0 Or index >= arraySize Then Throw New IndexOutOfBoundsException("Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then Return E(elements[i])
		Next
		Return defaultValue
	End
	
	Method Set:E(index:Int, value:E)
		If index < 0 Or index >= arraySize Then Throw New IndexOutOfBoundsException("Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then
				Local oldVal:Object = elements[i]
				elements[i] = value
				Return E(oldVal)
			End
		Next
		ResizeArrays()
		indices[size] = index
		elements[size] = value
		size += 1
		Return defaultValue
	End
	
	Method Clear:Int()
		For Local i% = 0 Until size
			elements[i] = Null
		Next
		Local oldSize:Int = size
		size = 0
		Return oldSize
	End
End

'summary: SparseIntArray
Class SparseIntArray
Private
	Field elements:Int[]
	Field indices:Int[]
	Field size:Int
	Field arraySize:Int
	Field defaultValue:Int
	
	' resizes the arrays if necessary to ensure they can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			indices = indices.Resize(newCapacity)
		End
	End
	
Public
	Method New(arraySize:Int=-1, defaultCapacity:Int=100, defaultValue:Int=0)
		AssertGreaterThanInt(defaultCapacity, 0, "Default capacity must be greater than 0!")
		elements = New Int[defaultCapacity]
		indices = New Int[defaultCapacity]
		Self.arraySize = arraySize
		Self.defaultValue = defaultValue
	End
	
	Method Size:Int() Property
		Return size
	End
	
	Method ArraySize:Int() Property
		Return arraySize
	End
	
	Method ArraySize:Void(arraySize:Int) Property
		AssertGreaterThanInt(arraySize, size, "The SparseIntArray contains more mappings than the requested size.")
		Self.arraySize = arraySize
	End
	
	Method DefaultValue:Int() Property
		Return defaultValue
	End
	
	Method DefaultValue:Void(defaultValue:Int) Property
		Self.defaultValue = defaultValue
	End
	
	Method Get:Int(index:Int)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then Return elements[i]
		Next
		Return defaultValue
	End
	
	Method Set:Int(index:Int, value:Int)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then
				Local oldVal:Int = elements[i]
				elements[i] = value
				Return oldVal
			End
		Next
		EnsureCapacity(size+1)
		indices[size] = index
		elements[size] = value
		size += 1
		Return defaultValue
	End
	
	Method Clear:Int()
		For Local i% = 0 Until size
			elements[i] = 0
		Next
		Local oldSize:Int = size
		size = 0
		Return oldSize
	End
End

'summary: SparseStringArray
Class SparseStringArray
Private
	Field elements:String[]
	Field indices:Int[]
	Field size:Int
	Field arraySize:Int
	Field defaultValue:String
	
	'summary: resizes the arrays if necessary to ensure they can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			indices = indices.Resize(newCapacity)
		End
	End
	
Public
	Method New(arraySize:Int=-1, defaultCapacity:Int=100, defaultValue:String="")
		AssertGreaterThanInt(defaultCapacity, 0, "Default capacity must be greater than 0!")
		elements = New String[defaultCapacity]
		indices = New Int[defaultCapacity]
		Self.arraySize = arraySize
		Self.defaultValue = defaultValue
	End
	
	Method Size:Int() Property
		Return size
	End
	
	Method ArraySize:Int() Property
		Return arraySize
	End
	
	Method ArraySize:Void(arraySize:Int) Property
		If arraySize >= 0 Then AssertGreaterThanInt(arraySize, size, "The SparseIntArray contains more mappings than the requested size.")
		Self.arraySize = arraySize
	End
	
	Method DefaultValue:String() Property
		Return defaultValue
	End
	
	Method DefaultValue:Void(defaultValue:String) Property
		Self.defaultValue = defaultValue
	End
	
	Method Get:String(index:Int)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then Return elements[i]
		Next
		Return defaultValue
	End
	
	Method Set:String(index:Int, value:String)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then
				Local oldVal:String = elements[i]
				elements[i] = value
				Return oldVal
			End
		Next
		EnsureCapacity(size+1)
		indices[size] = index
		elements[size] = value
		size += 1
		Return defaultValue
	End
	
	Method Clear:Int()
		For Local i% = 0 Until size
			elements[i] = ""
		Next
		Local oldSize:Int = size
		size = 0
		Return oldSize
	End
End

'summary: SparseFloatArray
Class SparseFloatArray
Private
	Field elements:Float[]
	Field indices:Int[]
	Field size:Int
	Field arraySize:Int
	Field defaultValue:Float
	
	' resizes the arrays if necessary to ensure they can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			indices = indices.Resize(newCapacity)
		End
	End
	
Public
	Method New(arraySize:Int=-1, defaultCapacity:Int=100, defaultValue:Float=0)
		AssertGreaterThanInt(defaultCapacity, 0, "Default capacity must be greater than 0!")
		elements = New Float[defaultCapacity]
		indices = New Int[defaultCapacity]
		Self.arraySize = arraySize
		Self.defaultValue = defaultValue
	End
	
	Method Size:Int() Property
		Return size
	End
	
	Method ArraySize:Int() Property
		Return arraySize
	End
	
	Method ArraySize:Void(arraySize:Int) Property
		AssertGreaterThanInt(arraySize, size, "The SparseIntArray contains more mappings than the requested size.")
		Self.arraySize = arraySize
	End
	
	Method DefaultValue:Float() Property
		Return defaultValue
	End
	
	Method DefaultValue:Void(defaultValue:Float) Property
		Self.defaultValue = defaultValue
	End
	
	Method Get:Float(index:Int)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then Return elements[i]
		Next
		Return defaultValue
	End
	
	Method Set:Float(index:Int, value:Float)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then
				Local oldVal:Float = elements[i]
				elements[i] = value
				Return oldVal
			End
		Next
		EnsureCapacity(size+1)
		indices[size] = index
		elements[size] = value
		size += 1
		Return defaultValue
	End
	
	Method Clear:Int()
		For Local i% = 0 Until size
			elements[i] = 0
		Next
		Local oldSize:Int = size
		size = 0
		Return oldSize
	End
End

'summary: See the commented code for an example of what your class should look like.
' Poolable objects need to retain a field that indicates whether or not they are active.  Since
' IPoolable is an interface, it cannot provide that field automatically.  You must create the field
' yourself and implement the properties to access it.
Interface IPoolable
'	Field activeInPool:Bool = False

	Method ActiveInPool:Bool() Property
'		Return activeInPool
'	End

	Method ActiveInPool:Void(activeInPool:Bool) Property
'		Self.activeInPool = activeInPool
'	End

	Method InitFromPool:Void(arg:Object = Null)
'		' This is like the constructor, it gets called when you call GetObject(arg)
'	End

	Method PurgedFromPool:Void()
'		' This is like the destructor, it gets called when the object is purged.
'	End
End

'summary: A pool will instantiate "capacity" number of "T" objects, then make those available to the GetObject() method.
' The type of these objects can NEVER change, so don't try to downcast it.  The point of pooling is to reduce the need for runtime
' object instantiation.
' To use the pool, instantiate it with your object type and the maximum number of objects in the pool.  The default constructor for
' your type will be used to fill the pool.  Your object must implement the IPoolable interface.
' To retrieve an object from the pool, use the GetObject() method.  To release it, simply set the ActiveInPool property on your
' object to false, and it will be released on the next purge.  Automatic purges happen in two cases; before an EachIn, and before
' a Sort().  If you purge the pool during an EachIn, it will throw a ConcurrentModificationException to prevent you from looping on
' objects twice.  It is still possible to retrieve free objects during an EachIn, as the modifications to the pool will occur after the
' snapshot count, and will not affect the loop.
' When looping, it is still a good idea to check the active state of the object, in case you have released it at some point in your
' code.
' Note that if the pool is full, a call to GetObject() will return Null.
Class Pool<T>
Private
	Field comparator:IComparator = Null
	Field objects:Object[] ' we use Object[] instead of T[] so that we can pass it into QuickSort()
	Field activeCount:Int = 0
	Field capacity:Int
	Field modCount:Int = 0
	
	Method InitPool:Void(capacity:Int)
		If capacity <= 0 Then Throw New DiddyException("Pool capacity must be >= 0")
		Self.capacity = capacity
		objects = New Object[capacity]
		For Local i:Int = 0 Until capacity
			objects[i] = New T
			If i = 0 And Not IPoolable(objects[i]) Then Throw New DiddyException("Pool generic parameter must implement IPoolable!")
		Next
	End
	
Public
	'summary: Property to read comparator
	Method Comparator:IComparator() Property
		Return comparator
	End
	
	'summary: Property to write comparator
	Method Comparator:Void(comparator:IComparator) Property
		Self.comparator = comparator
	End
	
	'summary: Property to read capacity (read only)
	Method Capacity:Int() Property
		Return capacity
	End
	
	'summary: Property to read active count (read only)
	Method ActiveCount:Int() Property
		Return activeCount
	End
	
	'summary: Constructor that initialises to a capacity
	Method New(capacity:Int = 100)
		InitPool(capacity)
	End
	
	'summary: Retrieves the next free pooled object, optionally passing the arg to InitFromPool.
	'This is a good way to use template objects (copy fields manually).
	Method GetObject:T(arg:Object = Null)
		If activeCount >= capacity Then Return Null
		Local rv:T = T(objects[activeCount])
		activeCount += 1
		IPoolable(rv).ActiveInPool = True
		IPoolable(rv).InitFromPool(arg)
		Return rv
	End
	
	'summary: Shuffles object references so that they are contiguous (optimisation), and updates the active count.
	Method Purge:Void()
		Local current:Int = 0
		While current < activeCount
			' if the low index is active
			If IPoolable(objects[current]).ActiveInPool Then
				' move to the next index
				current += 1
			Else
				' else, reduce the active count until we find one to swap with
				While current < activeCount And Not IPoolable(objects[activeCount-1]).ActiveInPool
					modCount += 1
					activeCount -= 1
					IPoolable(objects[activeCount]).PurgedFromPool()
				End
				' if we have an active to swap, do it
				If current < activeCount Then
					modCount += 1
					Local oldObject:Object = objects[current]
					objects[current] = objects[activeCount-1]
					objects[activeCount-1] = oldObject
					IPoolable(oldObject).PurgedFromPool()
					activeCount -= 1
				End
			End
		End
	End
	
	'summary: Resets all objects (the Purge() call will ensure that PurgedFromPool() is called for each).
	Method Clear:Void()
		For Local i% = 0 Until activeCount
			IPoolable(objects[i]).ActiveInPool = False
		Next
		Purge()
	End
	
	'summary: Returns a Monkey-style enumerator for EachIn.
	Method ObjectEnumerator:PoolEnumerator<T>()
		Return New PoolEnumerator<T>(Self)
	End
	
	'summary: Performs a quicksort on the pool, doing a purge first.
	'Due to the way purging works, the pool will most likely become unsorted when items are purged.
	Method Sort:Void(reverse:Bool = False, comp:IComparator = Null)
		Purge()
		If activeCount <= 1 Then Return ' can't sort 0 or 1 elements
		If comp = Null Then comp = Self.Comparator
		If comp = Null Then comp = DEFAULT_COMPARATOR
		QuickSort(objects, 0, activeCount-1, comp, reverse)
		modCount += 1
	End
End

'summary: Monkey-style enumerator class for EachIn
'When you call EachIn, the pool is purged.  If you wish to loop on a sorted pool, call Sort() first (which also purges).
Class PoolEnumerator<T>
Private
	Field pool:Pool<T>
	Field snapshotActiveCount:Int
	Field currentIndex:Int
	Field modCount:Int
	
	Method New(pool:Pool<T>)
		Self.pool = pool
		Reset()
	End
	
	Method CheckConcurrency:Void()
		If modCount <> pool.modCount Then Throw New ConcurrentModificationException("PoolEnumerator.CheckConcurrency: Concurrent pool modification.")
	End
	
Public
	Method Reset:Void()
		pool.Purge()
		Self.currentIndex = 0
		Self.modCount = pool.modCount
		Self.snapshotActiveCount = pool.activeCount
	End
	
	Method HasNext:Bool()
		CheckConcurrency()
		Return currentIndex < snapshotActiveCount
	End

	Method NextObject:T()
		CheckConcurrency()
		If Not HasNext() Then Throw New IndexOutOfBoundsException("Couldn't get next object, index "+currentIndex+" >= "+snapshotActiveCount)
		currentIndex += 1
		Return T(pool.objects[currentIndex-1])
	End
End

'summary: QuickSort
Function QuickSort:Void(arr:Object[], left:Int, right:Int, comp:IComparator, reverse:Bool = False)
	If right > left Then
		Local pivotIndex:Int = left + (right-left)/2
		Local pivotNewIndex:Int = QuickSortPartition(arr, left, right, pivotIndex, comp, reverse)
		QuickSort(arr, left, pivotNewIndex - 1, comp, reverse)
		QuickSort(arr, pivotNewIndex + 1, right, comp, reverse)
	End
End

'summary: QuickSortPartition
Function QuickSortPartition:Int(arr:Object[], left:Int, right:Int, pivotIndex:Int, comp:IComparator, reverse:Bool = False)
	Local pivotValue:Object = arr[pivotIndex]
	arr[pivotIndex] = arr[right]
	arr[right] = pivotValue
	Local storeIndex:Int = left, val:Object
	For Local i:Int = left Until right
		If IComparable(arr[i]) <> Null Then
			If Not reverse And IComparable(arr[i]).Compare(pivotValue) <= 0 Or reverse And IComparable(arr[i]).Compare(pivotValue) >= 0 Then
				val = arr[i]
				arr[i] = arr[storeIndex]
				arr[storeIndex] = val
				storeIndex += 1
			End
		Else
			If Not reverse And comp.Compare(arr[i], pivotValue) <= 0 Or reverse And comp.Compare(arr[i], pivotValue) >= 0 Then
				val = arr[i]
				arr[i] = arr[storeIndex]
				arr[storeIndex] = val
				storeIndex += 1
			End
		End
	Next
	val = arr[storeIndex]
	arr[storeIndex] = arr[right]
	arr[right] = val
	Return storeIndex
End

Class ConcurrentModificationException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

Class IndexOutOfBoundsException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End
