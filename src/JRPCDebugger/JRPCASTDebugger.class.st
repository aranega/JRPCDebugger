Class {
	#name : #JRPCASTDebugger,
	#superclass : #JRPCDebugger,
	#category : #JRPCDebugger
}

{ #category : #actions }
JRPCASTDebugger >> context [
	^ self session currentContext
]

{ #category : #actions }
JRPCASTDebugger >> currentMethodNode [
	^ self currentNode methodNode
]

{ #category : #actions }
JRPCASTDebugger >> currentNode [
	^ self session currentNode
]

{ #category : #actions }
JRPCASTDebugger >> init: aString [
	process := DASTInterpreter new.
	process initializeWithProgram: (RBParser parseExpression: aString).
	session := process.
	^ self lineInfo
]

{ #category : #actions }
JRPCASTDebugger >> resume [
	^ JRPCDEvalInfo result: process evaluate.
]
