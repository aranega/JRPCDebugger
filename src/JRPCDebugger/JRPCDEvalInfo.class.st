Class {
	#name : #JRPCDEvalInfo,
	#superclass : #Object,
	#instVars : [
		'result'
	],
	#category : #JRPCDebugger
}

{ #category : #accessing }
JRPCDEvalInfo class >> result: aString [
	^ JRPCDEvalInfo new result: aString; yourself
]

{ #category : #converting }
JRPCDEvalInfo >> asJRPCJSON [
	^ self result asString
]

{ #category : #accessing }
JRPCDEvalInfo >> result [
	^ result
]

{ #category : #accessing }
JRPCDEvalInfo >> result: anObject [
	result := anObject
]
